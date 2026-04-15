# System Architecture: Beedle

**Date :** 2026-04-15
**Architecte :** Clement
**Version :** 1.0
**Type de projet :** mobile-app (Flutter, iOS + Android)
**Niveau BMAD :** 2
**Statut :** Draft

---

## Document Overview

Architecture système de **Beedle** — app mobile Flutter (iOS + Android) transformant des screenshots tech en fiches IA structurées avec activation par push locaux. Ce document est le plan technique d'implémentation pour les 16 FRs et 12 NFRs du PRD.

**Documents liés :**
- PRD : [`docs/prd-beedle-2026-04-15.md`](./prd-beedle-2026-04-15.md)
- Product Brief : [`docs/product-brief-beedle-2026-04-15.md`](./product-brief-beedle-2026-04-15.md)
- Brainstorming : [`docs/brainstorming-beedle-2026-04-15.md`](./brainstorming-beedle-2026-04-15.md)

---

## Executive Summary

Beedle est un **modular monolith client-side** en Flutter, avec un **proxy stateless Cloudflare Worker** pour les appels LLM et embeddings (protection des clés API + rate limiting). **Aucun backend custom** ne stocke de données utilisateur ; toute la persistance est **locale** (ObjectBox avec vector search) et cohérente avec l'angle privacy du produit. Le pipeline de capture → OCR local → LLM distant → embedding → persistance est **asynchrone** via ObjectBox-backed queue, robuste aux offlines et aux redémarrages OS.

**Choix techniques majeurs (dérivés des 8 questions ouvertes du PRD) :**

| Question | Décision | Driver principal |
|---|---|---|
| Q1 — OCR | Google ML Kit (Flutter plugin) | Unification iOS+Android, gratuit, suffisant sur screen mobile |
| Q2 — LLM | OpenAI GPT-4o-mini (abstraction `LLMProvider`) | NFR-004 (coût) respecté avec marge ×50 |
| Q3 — Embeddings | OpenAI `text-embedding-3-small` | Cross-lingual, coût négligeable, pas d'assets ONNX à embarquer |
| Q4 — Stockage | **ObjectBox** (vector search natif) | NFR-003 (recherche < 500 ms), plugin Flutter officiel |
| Q5 — Clustering fusion | Heuristique simple (temps + Jaccard) | 0 coût IA au MVP ; fallback LLM en V2 |
| Q6 — SC1 iOS | Accepté : import manuel + SC15 | Limitation OS assumée |
| Q7 — Timing push | Heuristique (horaires fixes + exclusion nuit + espacement ≥ 6 h) | Pas de learning au MVP |
| Q8 — Freemium cap | **Option B "strict"** : 10 fiches/mois free, 1 push-teaser/jour, recherche limitée | Maximise conversion trial → paid |

---

## Architectural Drivers

Les exigences qui pilotent le design :

1. **NFR-005 (privacy, local-first)** → Pas de backend custom de données. Seul un proxy stateless pour protéger les clés API. Aucune image ne sort du device.
2. **NFR-003 (recherche < 500 ms sur 1000 fiches)** → Choix d'ObjectBox pour le vector search natif sur device.
3. **NFR-004 (coût IA < 0,05 €/fiche)** → OCR on-device (gratuit) + GPT-4o-mini + text-embedding-3-small = ~0,001 €/fiche (marge ×50).
4. **NFR-002 (LLM < 15 s)** → Pipeline 100 % asynchrone avec queue persistante ObjectBox + retry exponential backoff. UI non-bloquante.
5. **NFR-001 (OCR < 3 s)** → ML Kit on-device, exécution sur iso­late Dart pour ne pas bloquer l'UI.
6. **NFR-009 (RGPD + Store compliance)** → Consent analytics explicite, export JSON, wipe complet, zéro image réseau.
7. **FR-001 (auto-import Android en background)** → `flutter_workmanager` périodique 15 min. iOS = non implémenté (SC15 compense).
8. **FR-010 (push intelligent)** → Scheduler local `flutter_local_notifications` avec règles côté client, pas de push serveur.
9. **Sécurité des clés API OpenAI** → Proxy Cloudflare Worker obligatoire (clés jamais dans le binaire app).

---

## System Overview

### High-Level Architecture

**Pattern :** Modular monolith Flutter (single app, feature modules), couches Clean Architecture (domain / data / presentation), pipeline asynchrone avec queue persistante.

Un proxy stateless (Cloudflare Worker, ~50 LOC) masque les clés API tiers et applique du rate-limiting par utilisateur anonyme (identifiant RevenueCat App User ID). Pas de base de données côté serveur. Pas de stockage utilisateur hors du device.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Device Mobile (iOS / Android)                   │
│                                                                     │
│  ┌───────────────────┐  ┌──────────────────┐  ┌─────────────────┐   │
│  │   Features UI     │  │  Domain /        │  │   Data Layer    │   │
│  │  (onboarding,     │──│  Use Cases       │──│ (ObjectBox +    │   │
│  │   home, search,   │  │  (Bloc states)   │  │  vector search) │   │
│  │   detail, paywall)│  │                  │  │                 │   │
│  └─────────┬─────────┘  └────────┬─────────┘  └────────┬────────┘   │
│            │                     │                     │            │
│            │    ┌────────────────┴─────────────────┐   │            │
│            │    │  Ingestion Pipeline (async)     │   │            │
│            │    │  Queue → OCR → LLM → Embedding  │───┤            │
│            │    │  → Persist → Notif Scheduler    │   │            │
│            │    └────────────────┬─────────────────┘   │            │
│            │                     │                     │            │
│  ┌─────────┴─────────┐  ┌────────┴─────────┐  ┌────────┴────────┐   │
│  │  OS Integrations  │  │   Services       │  │ Local Services  │   │
│  │  (share_intent,   │  │  (LLM, Embed,    │  │ (Notifications, │   │
│  │   WorkManager,    │  │   OCR, Sub,      │  │  Scheduler,     │   │
│  │   photo picker)   │  │   Analytics)     │  │  Fusion heur.)  │   │
│  └───────────────────┘  └────────┬─────────┘  └─────────────────┘   │
└──────────────────────────────────┼──────────────────────────────────┘
                                   │
                  HTTPS (text only, no images)
                                   │
                          ┌────────┴─────────┐
                          │  Cloudflare      │  Stateless proxy :
                          │  Worker Proxy    │  - hides API keys
                          │  (~50 LOC)       │  - per-user rate limit
                          └────────┬─────────┘
                                   │
           ┌───────────┬───────────┴─────────┬─────────────────┐
           │           │                     │                 │
  ┌────────▼────┐ ┌────▼────┐ ┌──────────────▼──┐ ┌────────────▼────┐
  │ OpenAI      │ │ OpenAI  │ │  RevenueCat     │ │  PostHog (EU)   │
  │ GPT-4o-mini │ │ Embed   │ │  (subscriptions)│ │  (analytics)    │
  └─────────────┘ └─────────┘ └─────────────────┘ └─────────────────┘
```

### Architectural Pattern

**Modular monolith client-side + stateless proxy.**

**Rationale :**
- **Cohérent avec le positionnement privacy** (NFR-005). Aucune donnée utilisateur ne transite par un backend propriétaire.
- **Développement solo** : 1 codebase Flutter, pas d'ops serveur à maintenir.
- **Coûts d'infra minimes** : Cloudflare Worker $5/mo couvre largement les premiers milliers d'utilisateurs. OpenAI facturé à l'usage. RevenueCat et PostHog gratuits jusqu'à des volumes très au-dessus du MVP.
- **Scalabilité déléguée** aux tiers (Cloudflare, OpenAI) — pas de capacity planning propre à faire.
- **Latence** : les appels réseau se font en arrière-plan (pipeline async), l'UI ne les attend jamais.

---

## Technology Stack

### Frontend / Framework

**Choix :** **Flutter** (stable channel, version 3.x+ au moment du dev).

**Rationale :** Décision amont (brief). Permet un binaire iOS + Android unifié en solo dev, avec un écosystème de plugins mûr pour OCR, notifications locales, share intents, ObjectBox, RevenueCat, PostHog.

**State management :** **`flutter_bloc`** (Bloc pattern).

**Rationale :** Pattern de référence Flutter, excellente testabilité, aligné conventions VGV (plugin `vgv-wingspan` installé). Trade-off : verbeux mais explicite — acceptable pour un solo dev qui veut maintenir son propre code dans 6 mois.

**Alternative considérée :** Riverpod (moins verbeux). Rejeté par cohérence avec VGV et parce que le Bloc force une discipline qui prévient les régressions en solo.

**Navigation :** **`go_router`** (routing déclaratif). Gère le deep-link depuis share sheet et notifications.

**UI / Design :** Material 3 avec theming custom. Animations via Lottie ou Rive pour l'onboarding (écrans 1-5, 12).

**i18n :** `flutter_intl` + ARB. Langues : FR et EN (NFR-011).

### Backend

**Choix :** **Cloudflare Worker stateless** (TypeScript, ~50 LOC).

**Rationale :** Pas de "backend" au sens traditionnel. Le Worker est un simple proxy pour :
1. Masquer les clés OpenAI (elles ne sont jamais dans le binaire app).
2. Rate-limiter par utilisateur anonyme (header `X-User-Id` dérivé de RevenueCat App User ID).
3. Router `/v1/chat/completions` et `/v1/embeddings` vers OpenAI.

**Trade-off :**
- ✓ Protège les clés API, latence ajoutée négligeable (< 50 ms), coût 5 $/mois forfaitaire + volumes très tolérants (10 M req/mois inclus).
- ✗ Crée une dépendance externe et un single point of failure (mitigation : Cloudflare SLA 99,99 %, keys de secours).

**Alternatives rejetées :**
- Clés OpenAI en dur dans le binaire : trop risqué pour une app payante (reverse engineering + abuse).
- BYOK (bring-your-own-key) : exclut 95 % des utilisateurs non-techniques.

### Database

**Choix :** **ObjectBox** pour Flutter (version avec HNSW vector search, ObjectBox ≥ 4.0).

**Rationale :**
- Seule DB Flutter mûre avec **vector search natif on-device** (HNSW). Respecte NFR-003 (recherche < 500 ms).
- Stockage 100 % local, cohérent NFR-005 (privacy).
- Performances excellentes sur 1000+ entités (NFR-007).
- Plugin Flutter officiel, multiplateforme, licence BSL (OK pour usage commercial < 100 K utilisateurs).

**Alternatives rejetées :**
- **SQLite + sqlite-vec extension** : setup multiplateforme complexe en Flutter (compilation native par OS), maintenance pénible en solo.
- **Isar** : populaire mais pas de vector search natif → ajouterait complexité embedding lookup.
- **Drift** : pas de vector search.

### Infrastructure

**Device (client) :** iOS 15+ et Android 8+ (API 26+) — cf. NFR-006.

**Cloud (proxy uniquement) :** **Cloudflare Workers** (edge, global, serverless).

**Stockage fichiers :** local uniquement. Screenshots stockés dans l'app sandbox (chiffré OS par défaut sur iOS 15+ et Android 7+). Aucun stockage cloud côté Beedle.

### Third-Party Services

- **OpenAI API** — GPT-4o-mini (digestion), text-embedding-3-small (embeddings). Abstraction `LLMProvider` pour swap ultérieur (Anthropic, Google).
- **RevenueCat** — paywall + subscriptions cross-platform (free jusqu'à $2.5K MTR).
- **PostHog** (région EU — Francfort) — analytics produit + feature flags (free jusqu'à 1 M events/mois).
- **Sentry** *(optionnel, recommandé)* — crash reporting (free dev plan).
- **Apple App Store Connect** + **Google Play Console** — distribution.

### Development & Deployment

- **Version control :** Git, GitHub.
- **CI/CD :** GitHub Actions — `pull_request` lance `flutter analyze`, `flutter test`. `main` tag → build Fastlane (iOS + Android) → TestFlight + Internal Testing.
- **Build tooling :** Fastlane pour automatiser signatures et uploads.
- **Secrets management :** `flutter_secure_storage` pour l'App User ID RevenueCat et les tokens transitoires. Env variables (via `--dart-define` + `.env` git-ignored) pour Worker URL et PostHog public key.
- **Obfuscation :** release builds avec `--obfuscate --split-debug-info=./symbols/`.
- **Tests :** `flutter_test` (unit + widget) + `mocktail` (mocks). Cible ≥ 60 % sur domain + services.
- **Linter :** `very_good_analysis` (VGV conventions) ou `flutter_lints` strict.
- **Monitoring post-launch :** PostHog dashboards + Sentry + Cloudflare Worker analytics.

---

## System Components

### C1 — App Shell, DI & Navigation

**Purpose :** Bootstrap de l'app, injection de dépendances, routage, theming, i18n.

**Responsabilités :**
- Initialisation ObjectBox, RevenueCat, PostHog, Sentry au démarrage.
- Wiring des services via `get_it` ou Bloc provider tree.
- Router `go_router` déclaratif gérant deep-links (notif tap → fiche, share sheet → import flow).
- Theme Material 3 + extension custom.

**Interfaces :** Point d'entrée unique (`bootstrap.dart`). Pas d'API externe.

**FRs concernés :** transversal.

---

### C2 — Onboarding Module

**Purpose :** Parcours d'activation 12 écrans (FR-012), quiz (FR-013), permission primers (FR-015), paywall (délégué à C6).

**Responsabilités :**
- Séquence navigable des 12 écrans.
- Collecte quiz → persist `UserPreferences.quizAnswers`.
- Permission primers avant appels OS (notifs + photos).
- Tracking PostHog à chaque écran (`onboarding_step_*`).
- Flag `onboardingCompletedAt` à la fin.

**Interfaces :** Écran de 1re launch, accessible sinon via Settings → "Revoir l'onboarding".

**FRs concernés :** FR-012, FR-013, FR-015.

---

### C3 — Capture & Ingestion Pipeline

**Purpose :** Tout ce qui transforme un screenshot en Card — le cœur du produit.

**Sous-composants :**
- **Capture Sources :**
  - `AndroidAutoImport` (WorkManager périodique 15 min, scanne `/Pictures/Screenshots/`). FR-001.
  - `ShareIntentReceiver` (`receive_sharing_intent`). FR-003.
  - `ManualImportFlow` (photo picker). FR-002.
- **Job Queue :** `IngestionJob` entities en ObjectBox, traitées séquentiellement par un worker isolate Dart.
- **OCR Service :** wrapper `google_mlkit_text_recognition`, exécute sur isolate (NFR-001).
- **Fusion Engine :** heuristique temps (±5 min) + Jaccard ≥ 40 % sur tokens OCR → regroupe des screens en 1 Card (FR-006).
- **LLM Client :** appel HTTPS au Worker proxy → OpenAI GPT-4o-mini. Retry exponential backoff (3 tentatives, base 2 s). Timeout 25 s.
- **Embedding Client :** appel Worker proxy → text-embedding-3-small, output `Float32List` stocké dans `Card.embedding`.
- **Hook Generator :** génère `Card.teaserHook` (< 80 caractères). MVP : inclus dans le prompt LLM (champ structuré de sortie), pas de call séparé.

**FRs concernés :** FR-001 à FR-006.

---

### C4 — Card Repository & Surface

**Purpose :** Exposer les fiches et la recherche à l'UI.

**Sous-composants :**
- **CardRepository** : CRUD ObjectBox + vector search (HNSW) via `Box<Card>.query(...).nearestNeighbors(...)`.
- **Home Feature** : sélection de la "suggestion du jour" (algo : plus ancienne non-vue, pondérée par quiz tags) + "à revoir" (viewedAt > 14 j).
- **Search Feature** : barre de recherche, résultats live avec embeddings query via `embeddings_client`. Tri par cosine similarity descendante.
- **Card Detail Feature** : vue complète + actions (`[Ouvrir source]`, `[Ouvrir avec Claude/ChatGPT]`, `[Copier code]`, `[Marquer testé]`, `[Régénérer]`, `[Scinder]`, `[Supprimer]`).

**FRs concernés :** FR-007, FR-008, FR-009.

---

### C5 — Notifications Engine

**Purpose :** Scheduler local des deux boucles de push (teaser + capture daily).

**Sous-composants :**
- **TeaserScheduler** : calcule les créneaux valides (12:00 / 18:00 par défaut, ajustés selon `UserPreferences`, exclusion 22-8h, espacement ≥ 6 h, max 2/jour ou 1/jour free). Sélectionne la Card candidate prioritaire (non vue depuis > 7 j + tag match quiz). Schedule via `flutter_local_notifications`. FR-010.
- **CaptureReminderScheduler** : 1 notif/jour à horaire fixe choisi par user, skippée si import dans les 6 h avant. FR-011.
- **NotificationHandler** : gère les taps → deep-link vers Card detail ou import flow.

**FRs concernés :** FR-010, FR-011.

---

### C6 — Subscription Service (RevenueCat wrapper)

**Purpose :** Gérer trial + Pro + freemium cap Option B (10 fiches/mois, 1 push/jour, recherche limitée).

**Responsabilités :**
- Wrapper RevenueCat SDK. Expose un stream `SubscriptionState { tier, trialExpiresAt }`.
- Paywall UI réutilisable (écran OB 10 + accès depuis settings + depuis gate de feature Pro).
- **Gate logic** :
  - Génération de Card : compteur mensuel freemium, réinitialisé chaque 1er du mois. Si tier=free et compteur ≥ 10 → écran paywall.
  - Push-teaser : max 1/jour en free (config override de C5).
  - Recherche : en free, query restreinte aux Cards générées dans le mois en cours (vector search filtré par date).
- Restore purchases.
- Webhook → PostHog pour tracking conversion/churn (via RevenueCat integration).

**FRs concernés :** FR-014.

---

### C7 — Analytics Service (PostHog wrapper)

**Purpose :** Tracking consent-guarded, events critiques, feature flags.

**Responsabilités :**
- Init SDK PostHog (EU region). Anonymous `distinct_id` local (UUID stocké en `flutter_secure_storage`).
- `AnalyticsConsent` singleton lu depuis `UserPreferences`. Si `false`, aucun event ne part.
- Event catalog centralisé (`analytics_events.dart`) pour éviter le freestyle de nommage.
- User properties depuis quiz (Q1, Q2, Q3) envoyées via `posthog.identify()` anonyme.
- Feature flags exposés via `FeatureFlagService` pour A/B test OB et prix post-launch.

**FRs concernés :** FR-016.

---

### C8 — Settings & Data Management

**Purpose :** Préférences utilisateur, RGPD, révision OB.

**Responsabilités :**
- UI settings (langue UI, horaire notif capture, nb teasers/jour, theme).
- Bouton "Exporter mes fiches en JSON" → partage système (NFR-009).
- Bouton "Supprimer toutes mes données" → wipe ObjectBox + RevenueCat logout + PostHog reset.
- Re-jouer l'onboarding.
- Désactiver analytics (toggle consent).
- Lien vers Privacy Policy et Terms.

**FRs concernés :** NFR-009.

---

## Data Architecture

### Data Model

Entités ObjectBox (`@Entity`) :

#### `Card` (entité primaire)
```
id              Long (auto)
uuid            String (unique)
title           String
summary         String
steps           List<String>  (étapes/sommaire)
codeBlocks      List<String>  (blocs code extraits)
level           String        (beginner | intermediate | advanced)
estimatedMinutes int?
language        String        (fr | en)
tags            List<String>  (max 5, auto-générés)
sourceUrl       String?       (détectée dans OCR)
teaserHook      String        (< 80 chars, pour push-teaser)
status          String        (pending | generated | failed)
embedding       HnswIndex<Float32List>  (1536 dims — text-embedding-3-small)
createdAt       DateTime
viewedAt        DateTime?
testedAt        DateTime?
viewedCount     Int
```

#### `Screenshot` (belongs to Card via relation)
```
id                Long (auto)
cardId            Long (ref Card)
filePath          String         (sandbox local)
ocrText           String
ocrConfidence     Double
captured­At        DateTime
imageSha256       String         (dedup via hash)
```

#### `IngestionJob`
```
id               Long (auto)
screenshotIds    List<Long>
status           String    (queued | processing | completed | failed)
attempts         Int
lastError        String?
createdAt        DateTime
completedAt      DateTime?
```

#### `NotificationRecord`
```
id              Long (auto)
cardId          Long?          (null pour push-capture)
type            String         (teaser | capture)
scheduledAt     DateTime
sentAt          DateTime?
tappedAt        DateTime?
dismissedAt     DateTime?
```

#### `UserPreferences` (singleton)
```
id                         Long (toujours 1)
onboardingCompletedAt      DateTime?
quizAnswers                Map<String, String>
captureReminderHour        Int      (0-23, default 20)
teaserCountPerDay          Int      (0/1/2)
uiLanguage                 String   (fr | en | system)
analyticsConsent           Boolean
themeMode                  String   (light | dark | system)
```

#### `SubscriptionSnapshot` (singleton, sync RevenueCat)
```
id                   Long (toujours 1)
tier                 String    (free | pro)
trialExpiresAt       DateTime?
subscribedAt         DateTime?
lastSyncedAt         DateTime
appUserId            String    (RevenueCat)
monthlyGenerationCount Int     (pour freemium cap)
monthlyCycleStart    DateTime
```

#### `FreemiumUsageLog` (pour audit et reset mensuel)
```
id                Long (auto)
eventType         String     (card_generated | push_shown | search_run)
eventAt           DateTime
```

### Database Design

**Stratégie d'indexation ObjectBox :**
- `Card.createdAt` indexed → tri feed chronologique interne.
- `Card.viewedAt` indexed → algo home "à revoir" et scheduler teaser.
- `Card.embedding` HNSW index (dim=1536, metric=cosine) → recherche sémantique.
- `Screenshot.imageSha256` unique index → dédup des imports doubles.
- `Screenshot.cardId` indexed → lookup back-references.
- `IngestionJob.status` indexed → worker query "next pending".

**Rétention :**
- `FreemiumUsageLog` : purge entries > 90 jours à chaque démarrage app.
- `NotificationRecord` : purge entries > 180 jours.
- Pas de cap auto sur `Card` (c'est au user de supprimer, sauf au-delà de NFR-007 = 1000 où warning).

**Dédup :** hash SHA-256 du fichier screenshot → skip import si déjà en base.

### Data Flow — Pipeline de capture

```
[Screenshot apparaît]
       │
       ├─ Android auto-import (WorkManager tick 15min)
       ├─ Share sheet (share_intent callback)
       └─ Import manuel (user tap)
       │
       ▼
[CaptureDispatcher]
       │
       ▼
[Dédup check (sha256)] ──► exists? → skip
       │
       ▼
[Create Screenshot entity + IngestionJob]
       │
       ▼
[Worker isolate picks next job]
       │
       ▼
[OCR on device (MLKit)] ──► confidence < seuil → status=failed
       │
       ▼
[FusionEngine : chercher Card récente (<5min) avec Jaccard ≥ 40%]
       │
       ├── match trouvée → APPEND Screenshot à Card existante, relancer LLM pour régénération
       └── pas de match → nouvelle Card, status=pending
       │
       ▼
[LLM call via Worker] ──► timeout/failure → retry (3x, backoff)
       │                   après échec final → status=failed, user voit "retry"
       ▼
[Parse output JSON structuré → remplit Card fields + teaserHook]
       │
       ▼
[Embedding call via Worker] ──► store Card.embedding
       │
       ▼
[Card.status = generated, persist, emit event bus]
       │
       ▼
[UI réactive via Bloc stream]
       │
       ▼
[NotificationEngine schedule push-teaser pour cette Card (+ 4 à 24 h selon créneau dispo)]
       │
       ▼
[Analytics event : card_generated]
```

**Tolérance offline :** jobs persistent en ObjectBox. Au retour de connexion, worker reprend. UI indique "En attente de génération" sur les Cards `pending`.

---

## API Design

Il n'y a **pas d'API Beedle publique**. Les interactions réseau sont :

### External APIs consommées

- **OpenAI (via Worker proxy)** — `POST /v1/chat/completions`, `POST /v1/embeddings`
- **RevenueCat SDK** — pas d'appels manuels, géré par SDK
- **PostHog SDK** — idem
- **Apple / Google In-App Purchase** — via SDK natif (couvert par RevenueCat)

### Worker Proxy contract (minimal)

**Endpoint :** `https://beedle-proxy.{clement-account}.workers.dev`

```
POST /v1/chat/completions
Headers:
  X-User-Id: {RevenueCat App User ID, UUID anonyme}
  Content-Type: application/json
Body: {OpenAI-compatible payload}
Response: streaming ou JSON OpenAI-compatible
```

```
POST /v1/embeddings
Headers: idem
Body: {OpenAI-compatible payload}
Response: {embeddings array}
```

**Rate limiting Worker (via Cloudflare KV ou Durable Objects) :**
- Free tier user : 30 req/jour, 10 req/heure (marge au-dessus de 10 fiches/mois pour laisser de la place à la recherche + retries).
- Pro tier user : 200 req/jour, 50 req/heure.
- Burst : 5 req/10 sec.
- Réponse 429 si dépassé. L'app affiche "Ralentissez ou passez Pro".

Le tier est lu côté app depuis RevenueCat et envoyé en header `X-User-Tier`. Le Worker peut vérifier via webhook RevenueCat ou simplement faire confiance (acceptable au MVP, user n'a rien à gagner à mentir puisque il doit quand même avoir la subscription pour que les features Pro soient activées côté UI).

### API Auth

**Côté app → Worker :** pas de JWT. Identification anonyme via `X-User-Id` (RevenueCat App User ID). Protection anti-abuse via rate-limit.

**Côté Worker → OpenAI :** clé API OpenAI injectée via secret Cloudflare (`wrangler secret put OPENAI_API_KEY`).

**Pas d'authentification utilisateur Beedle** (cohérent NFR-005, pas de compte). RevenueCat App User ID sert uniquement à unifier un user cross-device **si** un jour on ajoute un compte (V2).

---

## Non-Functional Requirements Coverage

### NFR-001 : OCR < 3 s

**Requirement :** P95 extraction OCR < 3 s sur iPhone 12+ / Pixel 6+.

**Solution :**
- MLKit text recognition on-device, pas de réseau.
- Exécution sur isolate Dart (`compute` ou `Isolate.run`) pour ne pas bloquer UI thread.
- Pré-chargement du model MLKit au démarrage de l'app (warm-up).

**Validation :** benchmark sur devices de référence, 30 screenshots variés. Instrumentation interne `ocr_duration_ms` envoyée à PostHog.

---

### NFR-002 : LLM < 15 s

**Requirement :** P95 génération fiche < 15 s.

**Solution :**
- Prompt optimisé pour tokens minimaux (system prompt court, output JSON structuré avec schema).
- GPT-4o-mini (inférence rapide vs modèles plus gros).
- Proxy Worker proche de l'utilisateur (edge Cloudflare).
- UI non-bloquante (Card.status=pending affichée, user peut continuer).

**Validation :** P95 monitoré via PostHog `llm_duration_ms`.

---

### NFR-003 : Recherche sémantique < 500 ms sur 1000 fiches

**Requirement :** P95 recherche < 500 ms sur 1000 fiches.

**Solution :**
- ObjectBox HNSW vector index (dim 1536, cosine similarity).
- Embedding de la query calculé en amont (appel Worker, ~100 ms typique edge).
- Tri et filtrage en mémoire (pas de round-trip réseau pour le search lui-même).
- Cache LRU du dernier embedding query (évite re-appel si user tape 2 fois la même chose).

**Validation :** benchmark synthétique 1000 Cards, instrumentation `search_duration_ms`.

---

### NFR-004 : Coût IA < 0,05 €/fiche

**Requirement :** moyenne < 0,05 €/fiche générée.

**Solution (par fiche standard ~2 K input + 1 K output tokens) :**
- **LLM GPT-4o-mini** : 2K × 0.15 $ + 1K × 0.60 $ /1M = **0,00090 $** ≈ 0,00082 €
- **Embedding text-3-small** : 1K × 0.02 $ /1M = **0,00002 $**
- **Total par fiche** : **~0,001 €** — marge × 50 vs cible.
- Proxy Worker compute : négligeable (inclus dans plan Cloudflare forfait 5 $/mois).

**Validation :** instrumentation `ingestion_cost_estimate_cents` côté app, monitoring agrégé PostHog. Alerte si moyenne mensuelle > 0,05 €.

---

### NFR-005 : Privacy — stockage local, zéro image réseau

**Requirement :** stockage 100 % local, aucune image envoyée, seul le texte OCR transite.

**Solution :**
- Toutes les entités persistées dans ObjectBox local.
- Pipeline envoie `ocrText` uniquement au Worker — jamais de bytes image.
- `file_path` screenshot pointe vers app sandbox (sandbox chiffré par défaut iOS 15+ et Android 7+).
- Worker stateless : ne logge pas les prompts (configuration `console.log` désactivée sur `/v1/*`), ne stocke rien.
- OpenAI API : utiliser `store: false` dans les payloads si applicable, documenter dans privacy policy la policy zero-retention d'OpenAI API.

**Validation :** audit trafic réseau en dev (Charles/Proxyman), vérifier que `Content-Type: image/*` ne sort jamais. Revue privacy policy avant submission.

---

### NFR-006 : Compatibilité iOS 15+ / Android 8+

**Requirement :** support iPhone SE 3, iPhone 14, Pixel 5, Pixel 8, téléphone 4.7"-6.7".

**Solution :**
- Flutter 3.x compile sur iOS 12+ mais on cible iOS 15+ dans `Info.plist` et `Podfile`.
- Android `minSdkVersion 26` (API 26 = Android 8.0 Oreo).
- Matrix de tests manuels sur 4 devices cibles.
- Pas de fonctionnalité requérant iOS 17+ (ex : Interactive Widgets).

**Validation :** tests manuels + CI builds iOS + Android.

---

### NFR-007 : Scalabilité — 1000 Cards/user

**Requirement :** performante jusqu'à 1000 Cards par user.

**Solution :**
- ObjectBox tient des millions d'entités sans souci.
- HNSW vector index optimisé pour 10K+ entries.
- Pagination UI par défaut (40 Cards/page en vue liste "Parcourir").
- Au-delà de 1000, warning UI suggérant archivage.

**Validation :** benchmark synthétique.

---

### NFR-008 : Offline

**Requirement :** OCR + recherche + navigation offline. Génération IA différée si offline.

**Solution :**
- OCR on-device → OK offline.
- Recherche embeddings : embedding de la query nécessite réseau (envoi au Worker). **Limitation connue** : search impossible offline. Mitigation : cache LRU des 20 dernières queries.
- Navigation home + détail : 100 % local.
- `IngestionJob` queue persiste offline, reprise automatique via connectivity_plus stream.
- Banner non-bloquant "Hors connexion — la génération reprendra plus tard".

**Validation :** test manuel mode avion.

---

### NFR-009 : RGPD + Store compliance

**Requirement :** conformité totale.

**Solution :**
- Privacy Policy publiée, lien dans app et stores.
- Consent analytics explicite en écran OB (ou premier lancement). Opt-out accessible dans Settings.
- **Apple Privacy Nutrition Label** :
  - Data Not Linked To You : Analytics (Product Interaction, Performance Data).
  - Data Not Collected : Photos (traitées sur device), Identifiers (sauf si consent).
  - Data Used to Track : **Non**.
- **Google Play Data Safety** : idem logique.
- Export JSON (NFR-009 doublon FR implicite) : sérialise Cards + Screenshots metadata (pas les bytes image, trop gros) en JSON.
- Wipe complet : supprime ObjectBox, RevenueCat logout, PostHog reset, efface sandbox files.

**Validation :** review Privacy Policy par Clement avant submission. Test manuel wipe + export.

---

### NFR-010 : Accessibilité

**Requirement :** WCAG AA minimum.

**Solution :**
- Palette couleurs vérifiée via `axe` ou outil contrast checker.
- Cibles tactiles ≥ 44×44 via design system (bouton minimum).
- `Semantics` widgets Flutter sur boutons critiques et images.
- Test VoiceOver / TalkBack sur parcours OB + capture + fiche detail.
- `TextScaleFactor` supporté jusqu'à 1.5× sans casse layout.

**Validation :** accessibility scanner Android + audit manuel iOS.

---

### NFR-011 : i18n FR + EN

**Requirement :** UI bilingue, pipeline IA multilingue.

**Solution :**
- Flutter intl avec fichiers ARB `intl_fr.arb` + `intl_en.arb`.
- Langue UI suit l'OS par défaut, override dans Settings.
- OCR MLKit : Latin script native (FR + EN OK sans config).
- Prompt LLM : instruction "Respond in the language of the source content (fr or en)".
- Embeddings `text-embedding-3-small` : cross-lingual natif, une query FR peut matcher une Card EN et inversement.
- Tests : dataset bilingue en Jalon 0.

**Validation :** review manuelle strings FR + EN, test pipeline sur 5 screens EN + 5 FR.

---

### NFR-012 : Maintainabilité

**Requirement :** couverture tests ≥ 60 % sur logique métier.

**Solution :**
- Clean Architecture (domain / data / presentation) → testabilité.
- Use cases unit-testés avec `mocktail` sur repositories.
- Bloc tests via `bloc_test`.
- `very_good_analysis` lints strict.
- Pas de widget tests lourds au MVP (UI = itérative).
- Documentation inline minimale, README packages, ADR (Architecture Decision Records) dans `docs/adr/` pour les choix structurants.

**Validation :** `flutter test --coverage` en CI, rapport lcov.

---

## Security Architecture

### Authentication

**Pas d'auth utilisateur.** L'app ne demande ni email ni mot de passe au MVP. L'identité "user" est l'App User ID anonyme de RevenueCat (UUID local).

### Authorization

Freemium cap (Option B) géré **côté app** via `SubscriptionService`. Côté Worker, rate-limit par tier (avec tolérance à la triche — acceptable au MVP : le user a besoin de la sub Pro de toute façon pour que l'app active les features).

### Data Encryption

**At rest :**
- Screenshots dans app sandbox (iOS : Data Protection classe `NSFileProtectionComplete` par défaut ; Android : FBE chiffré sur device).
- ObjectBox : chiffrement fichier DB optionnel via `encryptionKey` (recommandé, clé générée et stockée en `flutter_secure_storage` au 1er lancement).

**In transit :**
- TLS 1.3 tous appels réseau.
- App Transport Security iOS : enforce `NSAllowsArbitraryLoads = false`.
- Android : Network Security Config enforce HTTPS.

### Secrets Management

- **Clés OpenAI** : UNIQUEMENT dans Cloudflare Worker secret. Jamais dans le binaire app.
- **PostHog public key** : OK en binaire (c'est une public key, pas sensitive).
- **RevenueCat public key** : idem.
- **App signing keystores / provisioning profiles** : dans GitHub Actions secrets, accès restreint.

### Security Best Practices

- Input validation : OCR text sanitized avant insertion en prompt (échappement des chars qui pourraient induire prompt injection — via le schema JSON structured output d'OpenAI, le risque est limité).
- Pas de `eval()` / `Platform.executeProcess()` basé sur user input.
- Deep-link validation stricte (router go_router avec schéma typé).
- Dependency scanning : `pub outdated` en CI, Dependabot activé.
- Obfuscation release : `--obfuscate --split-debug-info`.
- Pas de storage sensitive dans `SharedPreferences`/`UserDefaults` clair → toujours `flutter_secure_storage`.

---

## Scalability & Performance

### Scaling Strategy

**Client-side :** pas de scaling nécessaire (1 install = 1 user).

**Worker :** Cloudflare scale automatiquement à l'échelle globale. Coût linéaire avec trafic, plan 5 $/mois = 10 M req/mois = largement au-delà du MVP.

**OpenAI :** scale pour nous. Rate limits API par organisation (niveau Tier auto-promu avec volume). Monitorer les 429 côté Worker, graceful degradation côté app ("Génération en attente").

### Performance Optimization

- OCR et tâches longues toujours sur isolate.
- Bloc avec `equatable` pour éviter rebuilds UI inutiles.
- `ListView.builder` avec `itemExtent` connu quand possible.
- `cached_network_image` pour avatars/assets (minimal au MVP mais bien faire d'emblée).
- Image Screenshots : pas de thumbnails générés en avance (génération à la demande au 1er affichage, mis en cache mémoire `ImageCache`).
- Embeddings : pas recalculés si l'OCR text n'a pas changé.

### Caching Strategy

- **Cache LRU embeddings query** : 20 dernières queries (~30 KB).
- **Cache mémoire des Cards visibles** (Bloc state).
- **Cache Worker** : pas de cache actif au MVP (les réponses LLM étant pseudo-uniques, peu de réutilisation possible). Cloudflare Cache-Control à `no-store`.

### Load Balancing

N/A côté Beedle. Cloudflare handles edge routing.

---

## Reliability & Availability

### High Availability Design

**Client :** chaque user est son propre silo. Pas de dépendance HA serveur entre users.

**Worker :** Cloudflare SLA 99,99 %, multi-region edge.

**OpenAI :** SLA tacite, monitoré. Fallback plan : basculer Worker sur Anthropic Haiku si OpenAI down prolongé (switch config sans déploiement app si LLMProvider abstrait côté Worker).

### Disaster Recovery

**Perte de device user** = perte des données. Accepté + mitigé par :
- Export JSON disponible (user responsabilité).
- V2 : sync cloud opt-in (iCloud, Google Drive) — pas au MVP.

**RPO / RTO côté Worker :** 0 / < 1 min (Cloudflare edge).

### Backup Strategy

Côté Beedle : aucun, local only. User responsable de ses exports (bouton fourni).

### Monitoring & Alerting

- **PostHog** : dashboards funnel OB, activation, conversion. Alertes sur drops brutaux (>30 % jour/jour).
- **Sentry** (recommandé) : crash rate, events error. Alerte sur crash rate > 1 %.
- **Cloudflare Worker Analytics** : req/s, error rate, P95 latency. Alerte sur error rate > 5 %.
- **App** : pas de monitoring temps réel ; user signale via mail support.

---

## Integration Architecture

### External Integrations

- **OpenAI** (via Worker) — sync HTTPS. Timeouts et retry côté client.
- **RevenueCat SDK** — stream `CustomerInfo`, webhooks optionnels vers PostHog.
- **PostHog SDK** — async events, offline queue intégrée au SDK.
- **Cloudflare Worker** — proxy transparent.
- **OS integrations** : WorkManager (Android), share intent (iOS + Android), notifications locales.

### Internal Integrations

- Communication inter-modules via **Bloc events** (pas de bus global) et **Repository interfaces injectées** via DI.
- Pipeline async : ObjectBox comme queue + stream de changements (`Query.stream()`) pour réactivité UI.

### Message/Event Architecture

Pas de message broker. Communication :
- **In-process event bus léger** (ex : `StreamController broadcast` dans `AppEventBus`) pour événements transverses (Card generated → refresh home + schedule notif + analytics).
- ObjectBox streams pour réactivité data → UI.

---

## Development Architecture

### Code Organization

Projet Flutter simple (pas de monorepo de packages) — adapté au solo dev MVP :

```
beedle/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── core/
│   │   ├── di/
│   │   ├── env/
│   │   ├── router/
│   │   ├── theme/
│   │   ├── l10n/
│   │   └── extensions/
│   ├── data/
│   │   ├── objectbox/
│   │   │   ├── objectbox_setup.dart
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── remote/
│   │       ├── llm_client.dart
│   │       └── embeddings_client.dart
│   ├── domain/
│   │   ├── entities/
│   │   ├── use_cases/
│   │   ├── services/
│   │   │   ├── ocr_service.dart
│   │   │   ├── fusion_engine.dart
│   │   │   ├── notification_scheduler.dart
│   │   │   ├── subscription_service.dart
│   │   │   └── analytics_service.dart
│   │   └── value_objects/
│   └── features/
│       ├── onboarding/    (bloc, widgets, screens)
│       ├── capture/
│       ├── home/
│       ├── card_detail/
│       ├── search/
│       ├── paywall/
│       └── settings/
├── test/
├── integration_test/
├── assets/
│   ├── images/
│   ├── animations/    (Lottie ou Rive)
│   └── i18n/          (ARB si pas dans lib/)
├── worker/            (Cloudflare Worker source, TypeScript, ~50 LOC)
│   ├── src/index.ts
│   └── wrangler.toml
├── ios/
├── android/
├── docs/              (BMAD docs + ADRs)
└── pubspec.yaml
```

### Module Structure

Chaque feature suit la convention :
```
features/home/
├── bloc/
│   ├── home_bloc.dart
│   ├── home_event.dart
│   └── home_state.dart
├── view/
│   ├── home_page.dart
│   └── widgets/
└── home.dart  (barrel export)
```

### Testing Strategy

- **Unit tests** : use cases, services (OCR, fusion, scheduler), repositories. Cible ≥ 60 %.
- **Bloc tests** : `bloc_test` sur blocs critiques (capture, home, paywall).
- **Integration tests** : pipeline complet (mock LLM/Embeddings clients) — 3-5 scénarios e2e (import → fiche → notif).
- **Widget tests** : minimaux, UI évolue trop.
- **Golden tests** : 12 écrans d'onboarding (c'est un asset figé, vaut l'investissement).

### CI/CD Pipeline

**GitHub Actions workflow :**

1. **PR trigger** :
   - `flutter analyze`
   - `flutter test --coverage`
   - Check coverage ≥ 60 %
2. **Merge to main** :
   - Tag version
   - Build iOS (Fastlane) → TestFlight
   - Build Android (Fastlane) → Play Console Internal Testing
3. **Manuel** : promotion TestFlight → App Store Review. Promotion Internal → Production.

### Environments

- **Dev local** — Worker `beedle-proxy-dev` + RevenueCat sandbox + PostHog dev project + OpenAI project dev avec cap bas.
- **Staging** (= TestFlight + Internal Testing) — Worker `beedle-proxy` + RevenueCat sandbox + PostHog prod project + OpenAI prod key.
- **Prod** (= App Store + Play Store) — idem staging mais via les users store paying.

Séparation staging/prod côté OpenAI : acceptable de partager la même key car rate-limit par user au Worker + les envs staging ont peu de users. Séparation stricte V2.

### Deployment Strategy

- **Mobile** : releases trackées avec les versions iOS/Android. Rollout progressif possible côté Play Store (staged rollout 5-20-50-100 %). App Store ne fait pas de rollout auto.
- **Worker** : `wrangler deploy` manuel ou via GH Actions sur `main`. Rollback via `wrangler rollback` ou commit revert.

### Infrastructure as Code

- **Worker** : `wrangler.toml` committé. Secrets via `wrangler secret put`.
- Pas d'autre infra.

---

## Requirements Traceability

### Functional Requirements Coverage

| FR ID | FR Nom | Composant(s) | Notes |
|-------|--------|--------------|-------|
| FR-001 | Auto-import Android | C3 — `AndroidAutoImport` (WorkManager) | 15-min periodic scan, dédup sha256 |
| FR-002 | Import manuel | C3 — `ManualImportFlow` | Photo picker natif multi-select |
| FR-003 | Share sheet | C3 — `ShareIntentReceiver` | `receive_sharing_intent` plugin |
| FR-004 | OCR local | C3 — `OCRService` (MLKit) | Isolate Dart |
| FR-005 | Digestion IA | C3 — `LLMClient` (Worker proxy → GPT-4o-mini) | Schema JSON structuré |
| FR-006 | Fusion multi-screens | C3 — `FusionEngine` heuristique | Temps + Jaccard |
| FR-007 | Home éditoriale | C4 — `HomeFeature` | Algo "suggestion du jour" + "à revoir" |
| FR-008 | Recherche sémantique | C4 — `SearchFeature` + ObjectBox HNSW | Cap cross-lingual |
| FR-009 | Vue fiche + actions | C4 — `CardDetailFeature` | Deep-link Claude/ChatGPT |
| FR-010 | Push-teaser | C5 — `TeaserScheduler` | Heuristique fenêtres + tags quiz |
| FR-011 | Push-capture | C5 — `CaptureReminderScheduler` | Skip si import récent |
| FR-012 | OB 12 écrans | C2 — `OnboardingModule` | Flow go_router dédié |
| FR-013 | Quiz perso | C2 — `OnboardingQuiz` | Persist `UserPreferences.quizAnswers` |
| FR-014 | Paywall RevenueCat | C6 — `SubscriptionService` | Gate freemium Option B |
| FR-015 | Permission primers | C2 — `PermissionPrimer` widgets | Primer → OS alert |
| FR-016 | Analytics PostHog | C7 — `AnalyticsService` | Consent-guarded |

**Couverture : 16/16 FRs.**

### Non-Functional Requirements Coverage

| NFR ID | NFR Nom | Solution Archi | Validation |
|--------|---------|----------------|------------|
| NFR-001 | OCR < 3s | MLKit on-device + isolate + pre-warm | Bench + PostHog `ocr_duration_ms` |
| NFR-002 | LLM < 15s | Async pipeline + UI non-bloquante + Worker edge | PostHog `llm_duration_ms` |
| NFR-003 | Search < 500ms | ObjectBox HNSW + cache LRU | Bench synthétique 1000 Cards |
| NFR-004 | Coût < 0,05€ | GPT-4o-mini + text-3-small = 0,001€/fiche | PostHog `ingestion_cost_estimate_cents` |
| NFR-005 | Privacy local | ObjectBox + Worker stateless + zéro image réseau | Audit trafic Proxyman |
| NFR-006 | Compat iOS 15+ / Android 8+ | minSDK configs + CI builds | Tests matrix devices |
| NFR-007 | 1000 Cards | ObjectBox scale + pagination + HNSW | Bench synthétique |
| NFR-008 | Offline | Queue ObjectBox + connectivity_plus | Test mode avion |
| NFR-009 | RGPD + stores | Consent + export JSON + wipe + Privacy Label | Checklist pré-submission |
| NFR-010 | WCAG AA | Design system + Semantics + tests scanner | Scanner + manuel |
| NFR-011 | FR + EN | intl + ARB + prompt multilingue + cross-lingual embeds | Tests dataset bilingue |
| NFR-012 | Maintainabilité | Clean Arch + very_good_analysis + coverage 60% | CI coverage report |

**Couverture : 12/12 NFRs.**

---

## Trade-offs & Decision Log

### TD-01 — Proxy Cloudflare Worker plutôt que clés API dans l'app

**Décision :** Worker stateless obligatoire pour les appels LLM/embedding.

**Trade-off :**
- ✓ Protection des clés API (bloqueur pour une app payante, le reverse engineering est trivial).
- ✓ Rate limit central (protection abuse).
- ✓ Coût négligeable (5 $/mois forfait).
- ✗ Dépendance à un tiers (Cloudflare). Mitigation : SLA 99,99 %.
- ✗ ~50 LOC TypeScript à maintenir (minimal).

### TD-02 — ObjectBox plutôt que SQLite + sqlite-vec

**Décision :** ObjectBox ≥ 4.0 avec HNSW natif.

**Trade-off :**
- ✓ Vector search natif cross-platform (Android + iOS) sans compilation custom.
- ✓ Plugin Flutter officiel et maintenu.
- ✓ Performance excellente sur HNSW.
- ✗ Licence BSL (OK jusqu'à 100K users — plus que suffisant au MVP).
- ✗ Moins de communauté que SQLite (mais stable).

### TD-03 — Bloc plutôt que Riverpod

**Décision :** `flutter_bloc`.

**Trade-off :**
- ✓ Pattern Flutter standard, excellente testabilité.
- ✓ Cohérent avec VGV conventions.
- ✗ Plus verbeux (3 fichiers par feature).
- ✗ Discipline explicite — choisi pour la maintenabilité solo long terme.

### TD-04 — Heuristique simple pour fusion multi-screens

**Décision :** Jaccard ≥ 40 % + fenêtre 5 min.

**Trade-off :**
- ✓ 0 coût IA.
- ✓ Implémentation triviale, testable exhaustivement.
- ✗ Cas limites ratés (tuto sur 2 jours, thread posté en 2 fois).
- Plan V2 : LLM-based clustering ou learning à partir du feedback "scinder/fusionner" user.

### TD-05 — GPT-4o-mini plutôt que Claude Haiku 4.5

**Décision :** OpenAI GPT-4o-mini au MVP, abstraction pour swap.

**Trade-off :**
- ✓ Coût × 8 moins cher que Haiku (0,0009 vs 0,007 $/fiche).
- ✓ Structured output JSON schema natif (fiabilité parsing).
- ✓ Latence faible.
- ✗ Possiblement qualité inférieure en structuration profonde — **à benchmarker en Jalon 0**.

### TD-06 — Freemium Option B (strict : 10/mois, 1 push/jour, search limitée)

**Décision :** validée par produit.

**Trade-off :**
- ✓ Conversion trial → paid plus forte.
- ✗ Friction potentielle si user n'a pas senti la valeur à 10 fiches/mois.
- Monitoring : surveiller conversion rate + churn post-launch, prêt à passer en Option A si mauvais signaux.

### TD-07 — Pas d'auth utilisateur au MVP

**Décision :** zéro compte, RevenueCat App User ID local uniquement.

**Trade-off :**
- ✓ Cohérent privacy-first.
- ✓ Zéro friction d'onboarding sur l'auth.
- ✗ Perte data si device perdu.
- ✗ Pas de cross-device sync (V2).

### TD-08 — Android auto-import via WorkManager 15-min plutôt que FileObserver foreground

**Décision :** `flutter_workmanager` periodic 15 min.

**Trade-off :**
- ✓ Pas de foreground service notification visible (meilleure UX).
- ✓ Pattern standard, respectueux batterie.
- ✗ Jusqu'à 15 min de délai entre screenshot et fiche.
- ✗ Android peut différer les jobs en cas de Doze mode profond.
- Si délai problématique post-launch : passer à foreground service en V2.

---

## Open Issues & Risks

### OI-01 — Validation du prompt de digestion (Jalon 0)

**Status :** à résoudre AVANT tout dev Flutter.

Le PRD flag R1 "qualité du prompt" comme létal. Action : script standalone Python/TS appelant GPT-4o-mini avec le schema structured output, testé sur 15-20 screens réels du porteur. Critère d'arrêt : fiches que le porteur déclare "j'ai envie de relire".

### OI-02 — Plan annuel prix exact

Non tranché. À valider avant submission stores. Recommandation : 59 €/an (~ 5 €/mois équivalent, incentive net).

### OI-03 — Privacy policy texte définitif

À rédiger avant submission. Doit couvrir : OCR local, texte envoyé à OpenAI, stockage local, analytics PostHog, absence d'auth, durée de rétention (indéfinie, à la main du user).

### OI-04 — Assets visuels onboarding

À produire : 12 illustrations ou animations Lottie/Rive. Options : solo (Figma + assets libres / AI image gen), ou sous-traitance rapide (Dribbble designer sur 5-7 jours).

### OI-05 — Monitoring coût OpenAI réel

Mettre en place un dashboard Worker qui estime le coût cumulé par user (tokens trackés) pour détecter drift vs NFR-004.

### OI-06 — Comportement en cas de revoke permission Photos post-usage

Si user révoque la permission Photos sur iOS, l'import manuel casse. UI doit détecter et proposer "Aller dans Réglages".

### OI-07 — Gestion iOS Share Extension et memory limits

iOS Share Extensions sont limités à ~120 MB RAM. OCR MLKit peut passer mais pas garanti. Fallback : share extension enqueue le fichier, génération différée à l'ouverture de l'app principale.

---

## Assumptions & Constraints

### Assumptions

- Le Jalon 0 valide la qualité du prompt de digestion avant dev Flutter.
- Les users récents ont iOS 15+ / Android 8+ (~ 95 % du parc 2026).
- Les APIs OpenAI et RevenueCat restent stables sur le MVP.
- OpenAI ne met pas en place une contrainte "zero-data-retention" payante qui casserait notre privacy promise (à vérifier dans leurs TOS au moment de la submission).
- Cloudflare Workers restent le proxy de choix (si politique change, migration possible en quelques heures vers Fly.io / Supabase Edge / Deno Deploy).

### Constraints

- Deadline 2 mois jusqu'à launch public.
- Solo dev, pas de QA, pas de designer dédié.
- Stack imposée Flutter.
- iOS : pas d'auto-import Photos en background.
- Stores : review Apple 1-7 jours, Google < 1 jour.
- Budget infra : < 50 €/mois au MVP (Cloudflare 5 $ + OpenAI variable + App Store 99 $/an + Google 25 $ one-time).

---

## Future Considerations

Backlog technique V2+ dérivé de cet archi :

- **V2 — Sync cloud opt-in** (iCloud Drive / Google Drive) : backup + cross-device.
- **V2 — Comptes utilisateurs optionnels** : email + magic link, permet sync + partage.
- **V2 — Fusion LLM-based** : remplacer heuristique par un call dédié.
- **V2 — Re-surfaçage contextuel** (SC12) : détection d'activité (focus mode, apps ouvertes) — iOS Live Activities, Android Tiles.
- **V2 — Interface vocale** (SC13) : Whisper on-device + TTS.
- **V2 — Partage social** (J5 + SC8 + SC9) : génération posts depuis fiches, curations publiques.
- **V2 — Deep dive** : call modèle premium (GPT-4, Claude Sonnet) à la demande, monétisation add-on.
- **V3 — Multi-langue au-delà de FR/EN** : ES, DE, JP selon demande.
- **V3 — Web app / desktop** : partager la même DB via cloud sync.

---

## Approval & Sign-off

- [x] Technical Lead (Clement)
- [x] Product Owner (Clement)
- [n/a] Security Architect
- [n/a] DevOps Lead (solo, pas de rôle séparé)

---

## Revision History

| Version | Date | Auteur | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-15 | Clement | Initial architecture. Dérivée du PRD et du product brief du même jour. |

---

## Next Steps

### Phase 4 : Sprint Planning & Implementation

Lancer `/bmad:sprint-planning` pour découper les 4 epics en stories détaillées (~24-32 stories estimées), avec les composants architecturaux et files concrets mappés.

**Avant sprint planning** : **Jalon 0** (prototype prompt hors Flutter, 15-20 screens réels) — bloquant selon le PRD. Un échec ici impose de revoir l'architecture ou changer de modèle LLM avant le dev.

**Principes d'implémentation :**
1. Respecter les boundaries des composants C1-C8.
2. Implémenter les solutions NFR telles que spécifiées.
3. Ne pas contourner l'abstraction `LLMProvider` — rester prêt à swap.
4. Commiter les ADRs (`docs/adr/`) pour toute décision technique qui diverge de ce document.

---

**Document créé avec BMAD Method v6 — Phase 3 (Solutioning)**

*Prochaine étape : `/bmad:sprint-planning`.*

---

## Appendix A — Technology Evaluation Matrix

| Catégorie | Option retenue | Alternatives rejetées | Raison |
|---|---|---|---|
| Framework | Flutter | React Native, Native | Décision amont brief |
| State mgmt | flutter_bloc | Riverpod, Provider | Cohérence VGV, testabilité |
| OCR | Google ML Kit | Apple Vision, Tesseract | Cross-platform simple |
| LLM | GPT-4o-mini | Claude Haiku 4.5, Gemini Flash | Coût + structured output |
| Embeddings | text-embedding-3-small | ONNX on-device, Cohere | Coût négligeable + cross-lingual |
| Storage | ObjectBox | SQLite+vec, Isar, Drift | Vector search natif mûr |
| Router | go_router | auto_route, Beamer | Pattern officiel Flutter 3 |
| Notifs | flutter_local_notifications | awesome_notifications | Maturité |
| Share | receive_sharing_intent | flutter_share_receive | Maintenance active |
| Background | flutter_workmanager | foreground_service | UX batterie |
| Paywall | RevenueCat | Adapty, Glassfy | Generosity free tier |
| Analytics | PostHog (EU) | Firebase Analytics, Amplitude | Privacy + feature flags |
| Crash | Sentry | Firebase Crashlytics | Cross-platform consistent |
| Proxy | Cloudflare Worker | Fly.io, Deno Deploy | Coût + latence edge |
| CI | GitHub Actions | Codemagic, Bitrise | Gratuit suffisant |

---

## Appendix B — Capacity Planning

**Hypothèses MVP (3 mois post-launch) :**
- 1000 users installés, 500 MAU, 100 Pro payants (conversion 20 % trial).
- Par user Pro : ~3 fiches/jour = 90/mois. Par user free : 10 max/mois.
- Volume appels LLM : (100 × 90) + (400 × 10) = 13 000 fiches/mois ≈ 13 000 chat + 13 000 embedding + ~5 000 recherches = **31 000 req/mois**.
- Cloudflare Worker : 1 % du plan (10 M).
- OpenAI : coût ~0,001 €/fiche × 13 000 = **13 €/mois**.
- Revenue : 100 × 9 € × 70 % = **630 €/mois** (net Apple/Google).
- Gross margin : ~98 %.

Scalabilité linéaire et confortable jusqu'à ~10K users Pro.

---

## Appendix C — Cost Estimation (monthly at MVP launch)

| Poste | Coût mensuel | Notes |
|---|---|---|
| Apple Developer Program | 8,25 € | Amorti (99 $/an) |
| Google Play Dev | 0 € | One-time 25 $ payé avant |
| Cloudflare Workers | 5 $ (~ 4,60 €) | Forfait Workers Paid |
| OpenAI API | ~13 € | Variable selon usage (proj. MVP) |
| RevenueCat | 0 € | Free jusqu'à 2,5K $ MTR |
| PostHog EU | 0 € | Free jusqu'à 1M events/mois |
| Sentry | 0 € | Free dev plan |
| Domaine custom (optionnel privacy policy) | 1 € | Domain cheap |
| **Total MVP** | **~26 €/mois** | Parfaitement couvert par 3 abonnés Pro |

Break-even : **3 abonnés Pro**.
