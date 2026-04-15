# ADR-003 — Single-app `lib/`, pas de monorepo

**Date :** 2026-04-15
**Status :** Accepted
**Context :** `ARCHITECTURE.md` §1 décrit un monorepo `apps/ + packages/` (core_foundation, core_domain, core_data, core_presentation + api_agent_vocal). Le porteur (Clement) a demandé explicitement de ne pas utiliser ce découpage pour Beedle.

## Decision

Adapter l'architecture en **single-app** avec dossiers-couches dans `lib/` :

```
lib/
├── foundation/   (équivalent core_foundation)
├── domain/       (équivalent core_domain)
├── data/         (équivalent core_data)
├── presentation/ (équivalent core_presentation + theme)
├── core/         (providers Riverpod, routing)
├── application/  (services applicatifs spécifiques app)
└── features/     (présentation feature-first)
```

Toutes les règles de dépendance et les patterns (Freezed, Retrofit → Dio custom client, Riverpod, AutoRoute) sont conservés. Seule la structure physique change.

## Consequences

- ✓ Moins d'overhead (pas de pubspec par package, pas de melos).
- ✓ Plus simple pour un solo dev MVP.
- ✓ Toujours testable/extractable si on split plus tard.
- ✗ Impossible de contraindre les dépendances inter-couches au niveau pubspec (tout import autorisé). Mitigation : convention + éventuellement `import_lint` plus tard.
- **Trigger de refactor** : si on ouvre à un 2ᵉ dev ou si on veut publier des packages réutilisables.
