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

const RATE_LIMITS: Record<'free' | 'pro', { perHour: number; perDay: number }> = {
  free: { perHour: 10, perDay: 30 },
  pro: { perHour: 50, perDay: 200 },
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

async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  tier: 'free' | 'pro'
): Promise<boolean> {
  const limits = RATE_LIMITS[tier];
  const now = Date.now();
  const hourWindow = Math.floor(now / (60 * 60 * 1000));
  const dayWindow = Math.floor(now / (24 * 60 * 60 * 1000));

  const hourKey = `rl:${userId}:h:${hourWindow}`;
  const dayKey = `rl:${userId}:d:${dayWindow}`;

  const [hourRaw, dayRaw] = await Promise.all([kv.get(hourKey), kv.get(dayKey)]);
  const hourCount = parseInt(hourRaw || '0', 10);
  const dayCount = parseInt(dayRaw || '0', 10);

  if (hourCount >= limits.perHour || dayCount >= limits.perDay) {
    return true;
  }

  await Promise.all([
    kv.put(hourKey, String(hourCount + 1), { expirationTtl: 7200 }),
    kv.put(dayKey, String(dayCount + 1), { expirationTtl: 172800 }),
  ]);

  return false;
}

interface KVNamespace {
  get(key: string): Promise<string | null>;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void>;
}
