/**
 * Beedle Cloudflare Worker proxy.
 *
 * Responsabilités :
 * - Transparent proxy vers OpenAI (/v1/chat/completions, /v1/embeddings)
 * - Rate limiting par utilisateur anonyme (header X-User-Id = RevenueCat App User ID)
 * - Protection de la clé API OpenAI (jamais dans le binaire app)
 *
 * Env required (set via `wrangler secret put`) :
 * - OPENAI_API_KEY
 *
 * Env KV namespace (optionnel pour rate-limiting persistant) :
 * - RATE_LIMIT_KV
 */

export interface Env {
  OPENAI_API_KEY: string;
  RATE_LIMIT_KV?: KVNamespace;
}

const OPENAI_BASE_URL = 'https://api.openai.com';

/**
 * Server-side quotas. Source de vérité pour la facturation et l'anti-abus.
 *
 * - `perMonth` est aligné avec le paywall client :
 *     free = 15 scans IA / mois calendaire (UTC)
 *     pro  = 500 scans / mois (fair-use, bien au-dessus de P95)
 * - `perHour` / `perDay` sont des garde-fous anti-burst (abus / runaway loop).
 *
 * Un "scan" ici = 1 requête vers /v1/chat/completions ou /v1/embeddings.
 * L'app en émet 2 par carte (chat + embedding) — tenir compte de ça si on
 * tune les limites.
 */
const RATE_LIMITS: Record<
  'free' | 'pro',
  { perHour: number; perDay: number; perMonth: number }
> = {
  free: { perHour: 10, perDay: 30, perMonth: 30 }, // 15 cartes × 2 reqs = 30
  pro: { perHour: 120, perDay: 500, perMonth: 1000 }, // 500 cartes × 2 reqs
};

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // CORS preflight (au cas où un client web voudrait tester).
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(),
      });
    }

    const allowed = ['/v1/chat/completions', '/v1/embeddings'];
    if (!allowed.includes(url.pathname)) {
      return json({ error: 'Not found' }, 404);
    }

    const userId = request.headers.get('X-User-Id') || 'anonymous';
    const tier = (request.headers.get('X-User-Tier') || 'free') as 'free' | 'pro';

    // Rate-limit (si KV configuré — sinon best-effort per-instance).
    if (env.RATE_LIMIT_KV) {
      const limited = await checkRateLimit(env.RATE_LIMIT_KV, userId, tier);
      if (limited) {
        return json({ error: 'Rate limit exceeded' }, 429);
      }
    }

    // Proxy vers OpenAI.
    const openAIRequest = new Request(OPENAI_BASE_URL + url.pathname, {
      method: request.method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${env.OPENAI_API_KEY}`,
      },
      body: request.body,
    });

    const response = await fetch(openAIRequest);
    const text = await response.text();

    return new Response(text, {
      status: response.status,
      headers: {
        'Content-Type': 'application/json',
        ...corsHeaders(),
      },
    });
  },
};

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders(),
    },
  });
}

function corsHeaders(): Record<string, string> {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-User-Id, X-User-Tier',
  };
}

/**
 * Vérifie et incrémente les compteurs hour / day / month pour cet user.
 * Renvoie `true` si la requête doit être bloquée (quota dépassé).
 *
 * Le compteur mensuel utilise une clé `YYYY-MM` (UTC) — pas un rolling-30-days.
 * C'est ce qui permet au user de "recharger" le 1er du mois, comme côté client.
 */
async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  tier: 'free' | 'pro'
): Promise<boolean> {
  const limits = RATE_LIMITS[tier];
  const now = new Date();
  const hourWindow = Math.floor(now.getTime() / (60 * 60 * 1000));
  const dayWindow = Math.floor(now.getTime() / (24 * 60 * 60 * 1000));
  const monthWindow = `${now.getUTCFullYear()}-${String(
    now.getUTCMonth() + 1
  ).padStart(2, '0')}`;

  const hourKey = `rl:${userId}:h:${hourWindow}`;
  const dayKey = `rl:${userId}:d:${dayWindow}`;
  const monthKey = `rl:${userId}:m:${monthWindow}`;

  const [hourRaw, dayRaw, monthRaw] = await Promise.all([
    kv.get(hourKey),
    kv.get(dayKey),
    kv.get(monthKey),
  ]);
  const hourCount = parseInt(hourRaw || '0', 10);
  const dayCount = parseInt(dayRaw || '0', 10);
  const monthCount = parseInt(monthRaw || '0', 10);

  if (
    hourCount >= limits.perHour ||
    dayCount >= limits.perDay ||
    monthCount >= limits.perMonth
  ) {
    return true;
  }

  // TTL du compteur mensuel = 45 jours (survit au changement de mois avec marge).
  const monthTtl = 45 * 24 * 60 * 60;
  await Promise.all([
    kv.put(hourKey, String(hourCount + 1), { expirationTtl: 7200 }),
    kv.put(dayKey, String(dayCount + 1), { expirationTtl: 172800 }),
    kv.put(monthKey, String(monthCount + 1), { expirationTtl: monthTtl }),
  ]);

  return false;
}

interface KVNamespace {
  get(key: string): Promise<string | null>;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void>;
}
