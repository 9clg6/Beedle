# Beedle Proxy Worker

Stateless Cloudflare Worker qui masque la clé OpenAI et applique un rate-limit par utilisateur anonyme.

## Setup (one-time)

```bash
cd worker
npm install
npx wrangler login
# crée le KV namespace pour le rate limiting (optionnel mais recommandé)
npx wrangler kv:namespace create RATE_LIMIT_KV
# puis copie l'id retourné dans wrangler.toml → [[kv_namespaces]]

# injecte la clé OpenAI
npx wrangler secret put OPENAI_API_KEY
```

## Deploy

```bash
# dev (sous-domaine workers.dev)
npm run deploy:dev
# prod
npm run deploy
```

## Endpoints

- `POST /v1/chat/completions` — transparent proxy, accepte le JSON schema OpenAI.
- `POST /v1/embeddings` — transparent proxy.

### Headers requis (injectés par le client Flutter) :
- `X-User-Id` : RevenueCat App User ID (UUID anonyme).
- `X-User-Tier` : `free` ou `pro` (pour rate-limit différencié).

### Rate limits :
- free : 10/heure, 30/jour
- pro : 50/heure, 200/jour
