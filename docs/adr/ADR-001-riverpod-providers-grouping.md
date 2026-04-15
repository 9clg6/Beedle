# ADR-001 — Grouping Riverpod providers in layered files

**Date :** 2026-04-15
**Status :** Accepted
**Context :** `ARCHITECTURE.md` §9.2 demande 1 provider par fichier (pattern `{nom}.{type}.provider.dart`). Pour un MVP solo dev avec ~30 providers, cela crée ~30 fichiers trivialement wrappers.

## Decision

Regrouper les providers par couche dans des fichiers barrel :
- `lib/core/providers/data_providers.dart` — tous providers data (clients, datasources, repositories).
- `lib/core/providers/service_providers.dart` — services.
- `lib/core/providers/usecase_providers.dart` — use cases.
- `lib/core/providers/app_config.provider.dart` — singleton keepAlive seul en son fichier.
- `lib/core/providers/kernel.provider.dart` — bootstrap.

Les ViewModels restent dans leur feature dir via `@riverpod` code-gen (triade maintenue).

## Consequences

- ✓ Beaucoup moins de fichiers → review plus rapide, imports plus simples.
- ✓ Toujours typé, injection toujours testable (overrides via `ProviderScope`).
- ✗ Divergence textuelle vs ARCHITECTURE.md — à noter dans les onboardings futurs contributeurs.
- **Trigger de refactor** : si le projet grossit > 50 providers ou si on ouvre à un 2ᵉ dev, revenir au pattern 1 fichier/provider.
