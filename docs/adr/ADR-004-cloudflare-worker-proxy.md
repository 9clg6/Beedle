# ADR-004 — Cloudflare Worker stateless comme proxy OpenAI

**Date :** 2026-04-15
**Status :** Accepted
**Context :** Pour une app mobile payante, mettre les clés OpenAI dans le binaire est un risque majeur (reverse engineering). Il faut un proxy qui garde la clé serveur-side.

## Decision

Déployer un Cloudflare Worker TypeScript (~100 LOC) en proxy transparent vers `api.openai.com` pour `/v1/chat/completions` et `/v1/embeddings`.

- Auth anonyme via header `X-User-Id` (RevenueCat App User ID).
- Rate-limit par KV : free 10/h 30/j, pro 50/h 200/j.
- Coût ~5 $/mois forfait.

## Alternatives rejetées

- **Clés dans le binaire** : trop risqué pour une app payante.
- **BYOK (bring your own key)** : exclut 95 % des users non-tech.
- **Fly.io / Supabase Edge / Deno Deploy** : équivalents, Cloudflare choisi pour coût + edge.

## Consequences

- ✓ Clé API protégée, rate-limit centralisé.
- ✓ Latence ajoutée négligeable (< 50 ms edge).
- ✗ SPOF Cloudflare (SLA 99.99 %).
- ✗ 50 LOC TypeScript à maintenir.
- **Trigger de refactor** : si Cloudflare TOS change ou volumes explosent, basculer sur un backend plus conventionnel.
