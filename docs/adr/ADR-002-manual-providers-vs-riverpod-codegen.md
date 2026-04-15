# ADR-002 — Manual `Provider` for repositories and use cases, `@riverpod` for ViewModels only

**Date :** 2026-04-15
**Status :** Accepted
**Context :** `ARCHITECTURE.md` §9.3 utilise `@riverpod` code-gen sur tous les providers (endpoint, datasource, repo, usecase, service, viewmodel). Pour le MVP, minimiser les fichiers `.g.dart` à générer.

## Decision

- Utiliser `final Provider<X> xProvider = Provider<X>((ref) => ...)` (manuel, no codegen) pour : config, clients, datasources, repositories, use cases, services.
- Garder `@riverpod class XxxViewModel extends _$XxxViewModel` pour les ViewModels (pattern AsyncValue familier, testabilité `bloc_test`-like via `ref.read`).

## Consequences

- ✓ Moins de génération codegen → `build_runner` plus rapide.
- ✓ Injection équivalente, overrides compatibles, `ref.watch` inchangé.
- ✗ Pas de "auto-dispose" implicite pour les top-level `Provider`, mais ce n'est pas un enjeu pour des singletons de couche data.
- **Trigger de refactor** : si on a besoin de providers family (paramétrés) ou d'auto-dispose explicite, migrer au codegen.
