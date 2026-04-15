# Beedle

> La veille qui se rappelle à toi.

**Beedle** transforme tes screenshots tech en fiches IA structurées, puis te pousse activement à les consommer via des notifications contextuelles. Différentiateur vs Notion/Obsidian/Readwise : push actif, zéro saisie manuelle, home éditoriale.

## Quick start

```bash
# 1. Deps Flutter
flutter pub get

# 2. Code generation (Freezed, Riverpod, AutoRoute, ObjectBox, flutter_gen)
dart run build_runner build --delete-conflicting-outputs

# 3. LocaleKeys (EasyLocalization)
dart run easy_localization:generate -S assets/translations -f keys -O lib/generated -o locale_keys.g.dart

# 4. Run
flutter run
```

## Stack

- **Flutter** (iOS 15+, Android 8+)
- **Riverpod 2.x** + `@riverpod` codegen pour les ViewModels
- **AutoRoute** pour la navigation
- **Freezed** pour l'immutabilité et Union types
- **ObjectBox 4.x** avec HNSW vector search (recherche sémantique locale)
- **Google ML Kit** pour l'OCR on-device
- **OpenAI GPT-4o-mini + text-embedding-3-small** via proxy Cloudflare Worker (clés masquées)
- **RevenueCat** pour les abonnements
- **PostHog** (EU) pour les analytics consent-guarded
- **EasyLocalization** — FR + EN

## Architecture

Voir `ARCHITECTURE.md` (source de vérité, adapté single-app).
Décisions de conception dans `docs/adr/`.

## Documentation BMAD

- Brainstorming : `docs/brainstorming-beedle-2026-04-15.md`
- Product Brief : `docs/product-brief-beedle-2026-04-15.md`
- PRD : `docs/prd-beedle-2026-04-15.md`
- Architecture : `docs/architecture-beedle-2026-04-15.md`
- Sprint Plan : `docs/sprint-plan-beedle-2026-04-15.md`

## Status build autonome

Voir `BUILD_LOG.md` à la racine — récap de ce qui a été scaffoldé + TODO pour le user.
