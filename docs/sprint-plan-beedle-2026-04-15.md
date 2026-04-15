# Sprint Plan: Beedle

**Date :** 2026-04-15
**Scrum Master :** Clement (solo dev + assistance IA)
**Niveau projet :** 2
**Total stories :** 36 (dont 1 préalable Jalon 0)
**Total points :** ~128
**Sprints planifiés :** 4 × 2 semaines + préalable Jalon 0 (Week 0)
**Target launch public :** 2026-06-15

**Documents amont :**
- [Architecture](./architecture-beedle-2026-04-15.md)
- [PRD](./prd-beedle-2026-04-15.md)
- [Product Brief](./product-brief-beedle-2026-04-15.md)

---

## Executive Summary

36 stories découpées en un préalable bloquant (Jalon 0 — prompt validation hors Flutter) + 4 sprints de 2 semaines. **MVP perso livré à la fin du Sprint 2** (Clement peut utiliser l'app) ; **launch public à la fin du Sprint 4** (App Store + Play Store). Capacité calibrée pour un solo dev avec assistance IA ≈ 35 pts par sprint de 2 semaines.

**Jalons clés :**
- **Week 0 (2026-04-15 → 04-21)** — Jalon 0 prompt validé, scaffolding Flutter, Worker proxy
- **Fin Sprint 2 (~2026-05-15)** — MVP perso prêt pour validation 7 jours
- **Fin Sprint 4 (~2026-06-12)** — soumission stores
- **Launch public (~2026-06-15)** — app en ligne après review Apple/Google

---

## Préalable bloquant — Jalon 0 (Week 0)

⚠️ **Non négociable selon le PRD (R1 létal).** Doit être complété avant toute story Sprint 1 qui consomme le LLM.

### STORY-J00 : Prompt validation (hors Flutter)

**Epic :** pré-MVP
**Priorité :** **Bloquant**
**Points :** 3

**User Story :**
En tant que porteur, je veux valider sur 15-20 vrais screens que le prompt de digestion produit des fiches dont j'ai envie de relire, pour dé-risquer l'app avant de coder.

**Acceptance Criteria :**
- [ ] Script standalone (Python ou TypeScript) appelant GPT-4o-mini avec schema JSON structuré.
- [ ] Testé sur ≥ 15 screens réels du porteur (FR + EN mélangés).
- [ ] Output comparé : le porteur déclare "j'ai envie de relire" sur ≥ 70 % des fiches.
- [ ] Le prompt finalisé + schema JSON + résultats sont committés dans `prompts/v1/`.
- [ ] Estimation du coût moyen par fiche (en tokens et euros) notée dans un README.

**Technical Notes :** hors codebase Flutter. Peut se faire en 1 fichier `prompt_validation.py` avec `openai` lib. Utiliser Apple Vision (via `pyobjc` sur mac) ou Tesseract pour OCR en local (pas besoin de MLKit à cette étape). Output JSON attendu : `{title, summary, steps, code_blocks, level, estimated_minutes, language, tags, teaser_hook}`.

**Critère d'échec :** si < 50 % des fiches sont jugées bonnes, revoir le modèle (Haiku 4.5 ou Sonnet), le schema, ou le prompt. **Ne pas commencer Sprint 1** dans ce cas.

---

## Capacité & vélocité

**Équipe :** 1 dev (Clement) + assistance IA (Claude Code).
**Sprint length :** 2 semaines × 4 sprints.
**Jours productifs par sprint :** 10.
**Heures productives par jour :** 6h (target réaliste solo).
**Avec assist IA :** 1 point ≈ 1,5-2h effective → velocity ~35 pts / sprint 2 semaines.
**Capacité totale planifiée :** 4 × 35 = 140 pts.
**Committed sur le plan :** ~128 pts (marge 12 pts = ~9 % buffer).

> Note : la vélocité "40-50 pts" type entreprise n'est pas crédible en solo même avec IA, 35 pts est un target honnête. Si Sprint 1 dépasse de 20 %, ré-allouer Sprint 2.

---

## Story Inventory (36 stories)

### Infrastructure (4 stories — 11 pts)

#### STORY-000 : Scaffolding Flutter project
**Epic :** transversal · **Priority :** Must · **Points :** 3

```
As a dev
I want a Flutter project scaffold with Bloc, go_router, env, DI, theme, i18n
So that je peux commencer le feature dev immédiatement
```

**AC :**
- [ ] Flutter 3.x stable, iOS + Android targets (iOS 15+, minSdk 26).
- [ ] `flutter_bloc`, `go_router`, `get_it`, `flutter_intl` intégrés.
- [ ] Arborescence `lib/{core,data,domain,features}/` créée.
- [ ] Theme Material 3 de base, mode light/dark.
- [ ] `very_good_analysis` en analysis_options.yaml.
- [ ] `flutter analyze` et `flutter test` passent sur le scaffold vide.

---

#### STORY-001 : ObjectBox setup + entities
**Epic :** transversal · **Priority :** Must · **Points :** 3

```
As a dev
I want les 6 entités ObjectBox définies (Card, Screenshot, IngestionJob, NotificationRecord, UserPreferences, SubscriptionSnapshot) avec code-gen fonctionnel
So that la persistance locale est prête
```

**AC :**
- [ ] Entités annotées `@Entity`, relations `ToOne`/`ToMany` correctes.
- [ ] HNSW vector index sur `Card.embedding` (dim=1536, cosine).
- [ ] `objectbox generator` produit les fichiers sans erreur.
- [ ] Repositories de base (`CardRepository`, `ScreenshotRepository`) avec CRUD + tests unitaires.

---

#### STORY-002 : Cloudflare Worker proxy
**Epic :** transversal · **Priority :** Must · **Points :** 3

```
As a dev
I want un proxy Cloudflare Worker stateless qui masque la clé OpenAI et applique un rate-limit par user anonyme
So that je peux appeler OpenAI depuis l'app sans exposer de secrets
```

**AC :**
- [ ] Worker TypeScript déployé (`beedle-proxy.{account}.workers.dev`).
- [ ] Endpoints `/v1/chat/completions` et `/v1/embeddings` transparent proxy.
- [ ] Rate limit par `X-User-Id` (via Cloudflare KV ou in-memory pour MVP) : free 30/j 10/h, pro 200/j 50/h.
- [ ] Secret OpenAI via `wrangler secret`.
- [ ] README avec instructions de setup local + deploy.

---

#### STORY-003 : CI/CD basics
**Epic :** transversal · **Priority :** Should · **Points :** 2

```
As a dev
I want une CI qui tourne flutter analyze + test à chaque PR
So that je ne merge jamais du code cassé
```

**AC :**
- [ ] Workflow GitHub Actions `.github/workflows/ci.yml`.
- [ ] Jobs : `flutter analyze`, `flutter test --coverage`.
- [ ] Badge CI dans README.

---

### EPIC-02 — Pipeline Capture & Digestion (8 stories — 29 pts)

#### STORY-010 : OCR service (MLKit + isolate)
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 3 · **FRs :** FR-004

**AC :**
- [ ] `OCRService` wrappe `google_mlkit_text_recognition`.
- [ ] Exécution sur isolate (`compute`), n'bloque jamais UI thread.
- [ ] Retourne `OCRResult { text, confidence, detectedLanguage }`.
- [ ] Pré-warm du model au démarrage app.
- [ ] Tests unitaires avec images de fixtures.

---

#### STORY-011 : LLM client + structured output + retry
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 5 · **FRs :** FR-005

**AC :**
- [ ] Abstraction `LLMProvider` + impl `OpenAIProvider` via Worker.
- [ ] Structured output JSON schema (Card fields, inclus `teaser_hook`).
- [ ] Retry exponential backoff (base 2s, max 3 attempts).
- [ ] Timeout 25s par tentative.
- [ ] Dart classes générées depuis schema ou typage manuel sûr.
- [ ] Tests unitaires avec mock HTTP client (`mocktail`).

---

#### STORY-012 : Embedding client
**Epic :** EPIC-02 + EPIC-03 · **Priority :** Must · **Points :** 2 · **FRs :** FR-008 (base)

**AC :**
- [ ] `EmbeddingsClient` appelle Worker `/v1/embeddings` (text-embedding-3-small).
- [ ] Retourne `Float32List` dim 1536.
- [ ] Cache LRU 20 entrées (pour réutilisation query).
- [ ] Tests unitaires.

---

#### STORY-013 : Ingestion pipeline (queue + worker isolate)
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 5 · **FRs :** FR-005, support FR-001/002/003

**AC :**
- [ ] `IngestionJob` entities en ObjectBox forment la queue.
- [ ] Worker isolate picks next job, process (OCR → fusion check → LLM → embedding → persist).
- [ ] Status tracking (pending/processing/completed/failed).
- [ ] Retry logic sur échecs (incrémente `attempts`, `lastError`).
- [ ] Tolérance offline (reprise à la connexion via `connectivity_plus`).
- [ ] Event bus local émet `card_generated` à la fin.
- [ ] Tests integration avec mocks LLM/Embedding.

---

#### STORY-014 : Fusion engine (heuristique)
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 3 · **FRs :** FR-006

**AC :**
- [ ] `FusionEngine` : si screen arrive dans les 5 min d'une Card existante ET Jaccard tokens ≥ 40 % → append à la Card existante, déclenche régénération LLM.
- [ ] Sinon → nouvelle Card.
- [ ] Action manuelle "Scinder" + "Fusionner" depuis fiche detail (voir STORY-021).
- [ ] Tests unitaires sur 10 cas (même tuto, posts distincts, etc.).

---

#### STORY-015 : Import manuel depuis photo picker
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 3 · **FRs :** FR-002

**AC :**
- [ ] Bouton "Importer" sur home → photo picker natif (`image_picker` multi-select).
- [ ] Prévisualisation vignettes avant confirmation.
- [ ] Crée `IngestionJob` avec les screens sélectionnés, enqueue.
- [ ] Feedback progression (overlay loader + estimation temps).
- [ ] Permission Photos demandée via primer (STORY-042 later, placeholder basique).

---

#### STORY-016 : Share sheet iOS + Android
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 3 · **FRs :** FR-003

**AC :**
- [ ] `receive_sharing_intent` plugin configuré (iOS Share Extension + Android intent filter).
- [ ] Accepte `public.image`, `image/*`, `public.text`, `text/plain`.
- [ ] Partage multiple supporté.
- [ ] Déclenche `IngestionJob` en tâche de fond sans ouvrir l'app (notif locale de confirmation).
- [ ] Tests manuels sur iOS + Android avec Twitter, LinkedIn, Safari, Chrome.

---

#### STORY-017 : Auto-import Android (WorkManager 15 min)
**Epic :** EPIC-02 · **Priority :** Must · **Points :** 5 · **FRs :** FR-001

**AC :**
- [ ] `flutter_workmanager` periodic task 15 min.
- [ ] Scanne `/Pictures/Screenshots/` pour fichiers nouveaux (timestamp > last scan).
- [ ] Dédup via sha256 hash (`Screenshot.imageSha256` unique index).
- [ ] Skippe les screenshots antérieurs à l'installation de l'app.
- [ ] Respecte la pref user "auto-import activé".
- [ ] Non-implémenté iOS (compensé par SC15).
- [ ] Tests sur Pixel 6 réel.

---

### EPIC-03 — Surface & Recherche (4 stories — 17 pts)

#### STORY-020 : Home éditoriale
**Epic :** EPIC-03 · **Priority :** Must · **Points :** 5 · **FRs :** FR-007

**AC :**
- [ ] `HomePage` affiche 1 "suggestion du jour" en hero + 2-3 "à revoir".
- [ ] Algo suggestion : plus ancienne non vue, pondérée par tag match quiz OB, régénérée à 00:00 locale.
- [ ] "À revoir" : Cards dont `viewedAt > 14 jours` ou `viewedAt IS NULL`.
- [ ] Empty state si < 3 Cards : bouton "Importer mes premiers screens".
- [ ] CTA secondaire "Parcourir toutes mes fiches" → écran liste pagination.
- [ ] Tests Bloc + golden test sur hero state.

---

#### STORY-021 : Card detail + actions (SC6-light)
**Epic :** EPIC-03 · **Priority :** Must · **Points :** 5 · **FRs :** FR-009

**AC :**
- [ ] Affiche tous champs structurés (titre, résumé, étapes, code, niveau, temps, tags, langue).
- [ ] Boutons `[Copier code]`, `[Ouvrir source]` (si URL détectée), `[Ouvrir avec ChatGPT/Claude]` (deep-link app si installée, sinon web).
- [ ] `[Marquer comme testé]` → persist `testedAt`.
- [ ] Menu contextuel : `Régénérer` (V2 — hors MVP en implémentation complète, bouton placeholder accepté), `Scinder`, `Fusionner avec…`, `Supprimer`.
- [ ] Screenshots originaux en vignettes cliquables en bas.

---

#### STORY-022 : Recherche sémantique
**Epic :** EPIC-03 · **Priority :** Must · **Points :** 5 · **FRs :** FR-008

**AC :**
- [ ] `SearchPage` barre live search.
- [ ] Debounce 300 ms → call `EmbeddingsClient` → query HNSW via `CardRepository.nearestNeighbors`.
- [ ] Top 10 résultats avec vignette + extrait + score.
- [ ] Tolérance cross-langue (query FR → Cards EN OK).
- [ ] Cache LRU query (STORY-012).
- [ ] Empty state si pas de résultat : suggestion "reformule différemment".
- [ ] Tests perf : P95 < 500 ms sur 1000 Cards synthétiques (NFR-003).

---

#### STORY-023 : Parcourir toutes mes fiches
**Epic :** EPIC-03 · **Priority :** Should · **Points :** 2 · **FRs :** FR-007 (secondaire)

**AC :**
- [ ] Écran liste pagination 40 par page.
- [ ] Tri par date descendante par défaut.
- [ ] Filtres minimums : langue (FR/EN), niveau, "testé/non-testé".
- [ ] Swipe-to-delete avec confirmation.

---

### EPIC-04 — Push Engine (3 stories — 10 pts)

#### STORY-030 : Push-teaser (scheduler intelligent)
**Epic :** EPIC-04 · **Priority :** Must · **Points :** 5 · **FRs :** FR-010

**AC :**
- [ ] `TeaserScheduler` utilise `flutter_local_notifications`.
- [ ] Sélection Card candidate : non-vue depuis > 7 j, priorisée par tag match quiz.
- [ ] Timing : créneaux 12:00 / 18:00 par défaut (configurable), exclusion 22:00-08:00, espacement ≥ 6 h.
- [ ] Max 2 notifs/jour (1 en free plan par Option B — voir STORY-044).
- [ ] Contenu notif = `Card.teaserHook` (< 80 chars).
- [ ] Tap sur notif → ouvre Card detail.
- [ ] Tracking PostHog `notification_*` events.
- [ ] Tests unitaires sur scheduler logic.

---

#### STORY-031 : Push-capture daily
**Epic :** EPIC-04 · **Priority :** Must · **Points :** 3 · **FRs :** FR-011

**AC :**
- [ ] Notif locale daily à horaire user (default 20:00).
- [ ] 3-5 formulations tournantes (anti-lassitude).
- [ ] Skippée si import ≥ 1 dans les 6 h précédentes.
- [ ] Tap → ouvre import flow.
- [ ] Désactivable dans Settings.

---

#### STORY-032 : Deep-link notif → fiche ou import
**Epic :** EPIC-04 · **Priority :** Must · **Points :** 2 · **FRs :** support FR-010/011

**AC :**
- [ ] Router go_router gère deep-links `beedle://card/{uuid}` et `beedle://import`.
- [ ] `NotificationHandler` route correctement tap notif → écran cible.
- [ ] Back stack cohérent (pop ramène à Home).

---

### EPIC-01 — Onboarding, Monétisation & Analytics (9 stories — 33 pts)

#### STORY-040a : Onboarding écrans 1-5 (storytelling + preview features)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 5 · **FRs :** FR-012 (partie 1)

**AC :**
- [ ] Écran 1 Hero "La veille qui se rappelle à toi" + animation.
- [ ] Écran 2 Problem story (screens morts).
- [ ] Écran 3 Preview Capture (mockup animé import).
- [ ] Écran 4 Preview Digestion (avant/après screen → fiche).
- [ ] Écran 5 Preview Push (exemple de notif).
- [ ] Navigation forward/back, pas de skip avant écran 6.
- [ ] Tracking PostHog sur chaque écran.

---

#### STORY-040b : Onboarding écrans 6-8 (quiz + permission primers)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 5 · **FRs :** FR-012 (partie 2), FR-013, FR-015

**AC :**
- [ ] Écran 6 Quiz (3 questions : type contenu, fréquence push, horaire capture).
- [ ] Écran 7 Permission primer notifs → alerte OS.
- [ ] Écran 8 Permission primer photos → alerte OS.
- [ ] Réponses persistées en `UserPreferences`.
- [ ] Si refus au primer, skip l'alerte OS mais app reste fonctionnelle dégradée.

---

#### STORY-040c : Onboarding écrans 9-12 (trial / paywall / première capture / aha)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 5 · **FRs :** FR-012 (partie 3)

**AC :**
- [ ] Écran 9 Trial offer : mensuel 9 € OU annuel (prix à confirmer), mise en avant annuel.
- [ ] Écran 10 Paywall RevenueCat : skippable (CTA secondaire "Continuer en plan gratuit").
- [ ] Écran 11 Première capture guidée : l'user importe son 1er screen en direct.
- [ ] Écran 12 Aha moment : la fiche générée en temps réel + simulation d'un push-teaser.
- [ ] Flag `onboardingCompletedAt` en fin.
- [ ] Accessible ensuite via Settings → "Revoir l'onboarding".

---

#### STORY-041 : Quiz persist + injection prompt
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 3 · **FRs :** FR-013

**AC :**
- [ ] Quiz answers persisted → `UserPreferences.quizAnswers`.
- [ ] Injecté dans le system prompt LLM pour biais de structuration (ex : si user=Tech/IA, demander étapes applicables).
- [ ] Envoyé à PostHog comme user properties.

---

#### STORY-042 : Permission primers (widgets réutilisables)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 3 · **FRs :** FR-015

**AC :**
- [ ] Widget `PermissionPrimer` générique (titre, description, illustration, CTA).
- [ ] 2 variantes : notifs + photos.
- [ ] Logique : primer déclenche alerte OS si accepté, skip sinon.
- [ ] Écran "Aller dans Réglages" si user a refusé OS et veut réactiver.
- [ ] Tracking PostHog `permission_*` events.

---

#### STORY-043 : RevenueCat integration + paywall UI
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 5 · **FRs :** FR-014

**AC :**
- [ ] RevenueCat SDK intégré (iOS + Android).
- [ ] 2 produits configurés : `beedle_pro_monthly` (9 €, trial 7j) + `beedle_pro_yearly` (59 €, trial 7j — prix à confirmer).
- [ ] Entitlement `pro` exposé via `SubscriptionService` stream.
- [ ] Paywall UI réutilisable (hors OB aussi : Settings, feature gate).
- [ ] Restore purchases.
- [ ] Tracking via RevenueCat → PostHog integration.

---

#### STORY-044 : Freemium cap (Option B strict)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 3 · **FRs :** FR-014 (partie business)

**AC :**
- [ ] Compteur mensuel de générations (reset au 1er de chaque mois).
- [ ] Si `tier=free` et compteur ≥ 10 → écran "Cap atteint, passer Pro" blocant (redirection paywall).
- [ ] Push-teaser throttle : max 1/jour en free (override STORY-030).
- [ ] Recherche sémantique : en free, filtre les Cards à celles du mois en cours.
- [ ] Pro : tout débloqué.
- [ ] Test manuel des 3 gates.

---

#### STORY-045 : PostHog SDK + consent
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 3 · **FRs :** FR-016

**AC :**
- [ ] SDK PostHog (EU region — Francfort) intégré.
- [ ] `AnalyticsConsent` toggle dans UserPreferences.
- [ ] Distinct ID anonyme UUID stocké en `flutter_secure_storage`.
- [ ] Event catalog centralisé (`analytics_events.dart`).
- [ ] Bypass total si consent=false.

---

#### STORY-046 : Analytics instrumentation (events all over)
**Epic :** EPIC-01 · **Priority :** Must · **Points :** 3 · **FRs :** FR-016

**AC :**
- [ ] Instrumenter onboarding (chaque écran), capture (import, succès/échec génération), consommation (card opened, action tapped, search run), notifications (envoyé, tapé, dismiss), paywall (shown, trial, sub, churn).
- [ ] Revue du event catalog pour cohérence naming.

---

### Polish, Settings, Store Submission (8 stories — 21 pts + 5 buffer)

#### STORY-050 : Settings screen
**Priority :** Must · **Points :** 3 · **FRs :** support NFR-009/011

**AC :**
- [ ] Settings : langue UI, theme, horaire notif capture, nb teasers/jour, consent analytics, lien privacy policy.
- [ ] Pref updates immédiates sans redémarrage app.

---

#### STORY-051 : Export JSON + wipe complet
**Priority :** Must · **Points :** 2 · **FRs :** NFR-009

**AC :**
- [ ] "Exporter mes fiches" → partage système avec JSON (Cards + metadata, pas les bytes image).
- [ ] "Supprimer toutes mes données" avec confirmation → wipe ObjectBox + RevenueCat logout + PostHog reset + efface sandbox files.

---

#### STORY-052 : Privacy policy + Terms
**Priority :** Must · **Points :** 2 · **FRs :** NFR-009

**AC :**
- [ ] Privacy policy et Terms rédigées en FR + EN.
- [ ] Hébergées sur un domaine simple (Github Pages ou Cloudflare Pages).
- [ ] Accessibles dans l'app (Settings + Onboarding écran 9).

---

#### STORY-053 : i18n FR + EN
**Priority :** Must · **Points :** 3 · **FRs :** NFR-011

**AC :**
- [ ] Toutes les strings UI dans `intl_fr.arb` et `intl_en.arb`.
- [ ] Language switcher dans Settings.
- [ ] Langue par défaut = langue OS.
- [ ] Relecture manuelle des 2 locales.

---

#### STORY-054 : Accessibilité pass
**Priority :** Should · **Points :** 2 · **FRs :** NFR-010

**AC :**
- [ ] Contrastes vérifiés ≥ 4.5:1 sur tous les textes.
- [ ] Cibles tactiles ≥ 44×44 pt.
- [ ] `Semantics` widgets sur boutons critiques.
- [ ] Test VoiceOver + TalkBack sur flows OB + capture + fiche detail.

---

#### STORY-055 : Assets onboarding (illustrations / Lottie)
**Priority :** Must · **Points :** 3

**AC :**
- [ ] 12 assets (static ou animés Lottie/Rive) pour les 12 écrans OB.
- [ ] Produits en solo (Figma + AI image gen) ou sous-traités (Dribbble designer).
- [ ] Intégrés dans `assets/animations/` + `assets/images/`.

---

#### STORY-056 : TestFlight + Internal Testing setup
**Priority :** Must · **Points :** 3

**AC :**
- [ ] Fastlane iOS configuré (match pour certs, deliver pour TestFlight).
- [ ] Fastlane Android configuré (Play Console Internal Testing).
- [ ] Premier build distribué à 1-2 beta-testeurs.
- [ ] Doc `fastlane/README.md` pour les commandes.

---

#### STORY-057 : Store submission prep
**Priority :** Must · **Points :** 3

**AC :**
- [ ] Screenshots App Store (6.7"/6.5"/5.5" iOS + Android phone).
- [ ] Description store FR + EN.
- [ ] Mots-clés App Store + Google Play.
- [ ] Privacy Nutrition Label renseigné.
- [ ] Google Play Data Safety renseigné.
- [ ] Soumission effective.

---

#### Buffer intégré (~5 pts) — retours review Apple/Google + bugs de dernière minute.

---

## Sprint Allocation

### Sprint 1 (Weeks 1-2) — "Pipeline end-to-end" — 35 pts
**Période :** 2026-04-22 → 2026-05-05 (post Jalon 0)

**Goal :** À la fin du sprint, importer un screenshot manuel génère une fiche structurée visualisable en local.

| Story | Pts | Priority |
|---|---|---|
| STORY-000 Scaffolding | 3 | Must |
| STORY-001 ObjectBox + entities | 3 | Must |
| STORY-002 Worker proxy | 3 | Must |
| STORY-003 CI/CD basics | 2 | Should |
| STORY-010 OCR service | 3 | Must |
| STORY-011 LLM client | 5 | Must |
| STORY-012 Embedding client | 2 | Must |
| STORY-013 Ingestion pipeline | 5 | Must |
| STORY-015 Import manuel | 3 | Must |
| STORY-021 Card detail basique | 5 (basique — régénération V2) | Must |
| **Total** | **34** | |

**Risques :** temps underestimé sur STORY-011 (schema JSON stabilisé + retry) ou STORY-013 (coordination queue-worker-isolate).
**Dépendances :** Jalon 0 validé.
**Demo à la fin :** j'importe 1 screen, 15 s plus tard je vois la fiche structurée.

---

### Sprint 2 (Weeks 3-4) — "MVP perso — tous canaux + surface + push de base" — 35 pts
**Période :** 2026-05-06 → 2026-05-19

**Goal :** Clement peut utiliser l'app pendant 7 jours et valider les success criteria (J4 ≥ 4×/sem, notif ≥ 3×/sem).

| Story | Pts | Priority |
|---|---|---|
| STORY-016 Share sheet | 3 | Must |
| STORY-017 Auto-import Android | 5 | Must |
| STORY-014 Fusion engine | 3 | Must |
| STORY-020 Home éditoriale | 5 | Must |
| STORY-022 Recherche sémantique | 5 | Must |
| STORY-023 Parcourir fiches | 2 | Should |
| STORY-030 Push-teaser | 5 | Must |
| STORY-031 Push-capture daily | 3 | Must |
| STORY-032 Deep-link notif | 2 | Must |
| STORY-050 Settings (version minimale) | 3 | Must |
| **Total** | **36** | |

**Risques :** STORY-030 push-teaser couple data + scheduler + UX → plus complexe qu'il paraît.
**Dépendances :** Sprint 1 terminé.
**Demo / jalon :** "7 jours en usage réel Clement" démarre ici.

---

### Sprint 3 (Weeks 5-6) — "Onboarding + Monetization + i18n" — 35 pts
**Période :** 2026-05-20 → 2026-06-02

**Goal :** App publique-ready avec onboarding 12 écrans, paywall, analytics, bilingue.

| Story | Pts | Priority |
|---|---|---|
| STORY-040a OB 1-5 | 5 | Must |
| STORY-040b OB 6-8 quiz + primers | 5 | Must |
| STORY-040c OB 9-12 paywall + aha | 5 | Must |
| STORY-041 Quiz persist + prompt injection | 3 | Must |
| STORY-042 Permission primers widgets | 3 | Must |
| STORY-043 RevenueCat + paywall | 5 | Must |
| STORY-044 Freemium cap enforcement | 3 | Must |
| STORY-045 PostHog SDK + consent | 3 | Must |
| STORY-053 i18n FR + EN | 3 | Must |
| **Total** | **35** | |

**Risques :** STORY-040a/b/c assets-dépendants (STORY-055) → coordonner tôt. Paywall RevenueCat demande config Apple/Google avant, anticiper.
**Dépendances :** Sprint 2 terminé. Assets OB (STORY-055) démarré en parallèle.

---

### Sprint 4 (Weeks 7-8) — "Polish + Store launch" — 22 pts + 5 buffer
**Période :** 2026-06-03 → 2026-06-15

**Goal :** App publiée sur App Store + Play Store.

| Story | Pts | Priority |
|---|---|---|
| STORY-046 Analytics events all over | 3 | Must |
| STORY-051 Export JSON + wipe | 2 | Must |
| STORY-052 Privacy policy + Terms | 2 | Must |
| STORY-054 Accessibilité pass | 2 | Should |
| STORY-055 Assets OB illustrations | 3 | Must |
| STORY-056 TestFlight + Internal Testing | 3 | Must |
| STORY-057 Store submission prep | 3 | Must |
| STORY-050 Settings finalisation | +2 delta | Must |
| Buffer (bugs + review retour) | 5 | — |
| **Total** | **25 (+5 buffer)** | |

**Risques :** retour review Apple (1-7j) pouvant demander des ajustements. Garder le buffer.
**Dépendances :** Sprint 3 terminé. RevenueCat sandbox validé.

---

## Epic Traceability

| Epic | Stories | Total pts | Sprints |
|---|---|---|---|
| Préalable Jalon 0 | STORY-J00 | 3 | Week 0 |
| Transversal / Infra | STORY-000..003 | 11 | Sprint 1 |
| EPIC-02 Pipeline | STORY-010..017 | 29 | Sprint 1-2 |
| EPIC-03 Surface | STORY-020..023 | 17 | Sprint 2 |
| EPIC-04 Push Engine | STORY-030..032 | 10 | Sprint 2 |
| EPIC-01 Onboarding/Monetization | STORY-040a..046 | 33 | Sprint 3 |
| Polish + Store | STORY-050..057 | 21 + 5 buf | Sprint 4 |
| **Total** | **36 stories** | **~128 pts** | **4 sprints** |

---

## Functional Requirements Coverage

| FR ID | FR Nom | Story(ies) | Sprint |
|---|---|---|---|
| FR-001 | Auto-import Android | STORY-017 | 2 |
| FR-002 | Import manuel | STORY-015 | 1 |
| FR-003 | Share sheet | STORY-016 | 2 |
| FR-004 | OCR local | STORY-010 | 1 |
| FR-005 | Digestion IA | STORY-011 + STORY-013 | 1 |
| FR-006 | Fusion multi-screens | STORY-014 | 2 |
| FR-007 | Home éditoriale | STORY-020 + STORY-023 | 2 |
| FR-008 | Recherche sémantique | STORY-012 + STORY-022 | 1-2 |
| FR-009 | Card detail + actions | STORY-021 | 1 |
| FR-010 | Push-teaser | STORY-030 + STORY-032 | 2 |
| FR-011 | Push-capture | STORY-031 + STORY-032 | 2 |
| FR-012 | OB 12 écrans | STORY-040a + 040b + 040c + STORY-055 | 3-4 |
| FR-013 | Quiz perso | STORY-041 + STORY-040b | 3 |
| FR-014 | Paywall + freemium | STORY-043 + STORY-044 | 3 |
| FR-015 | Permission primers | STORY-042 + STORY-040b | 3 |
| FR-016 | Analytics PostHog | STORY-045 + STORY-046 | 3-4 |

**Coverage : 16/16 FRs.**

NFRs sont adressés transversalement (ObjectBox performance = NFR-003/007, Privacy Worker = NFR-005, RGPD STORY-051/052 = NFR-009, i18n STORY-053 = NFR-011, etc.).

---

## Risks & Dependencies

### Risques

| Risque | Sprint impacté | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Jalon 0 échoue (prompt médiocre) | pré-sprint 1 | Moyen | **Létal** | Itérer sur le prompt, essayer Haiku 4.5 si GPT-4o-mini insuffisant. Ne pas démarrer Sprint 1 avant succès. |
| Sprint 1 over-committed (pipeline complexe) | 1 | Moyen | Haut | Buffer Sprint 4 ; déprioriser STORY-003 (CI) si besoin. |
| RevenueCat sandbox pose problème | 3 | Moyen | Moyen | Démarrer la config RC dès Sprint 2 (prep). |
| Review Apple rejette (privacy, policy) | 4 | Moyen | Moyen | Rédiger privacy policy très détaillée, app sobre côté data collected. |
| Assets OB pas prêts | 3-4 | Faible | Moyen | Démarrer STORY-055 en parallèle Sprint 2. Fallback : illustrations simples CSS+icons sans Lottie. |
| Auto-import Android plus complexe que prévu (WorkManager + doze) | 2 | Moyen | Moyen | Si dépassement > 2 jours, basculer en foreground service (pattern VGV). |
| Coût OpenAI réel > estimation | post-launch | Faible | Moyen | Monitoring Worker + alerte > 0,05 €/fiche moyenne. |

### Dépendances externes

- **OpenAI API** : compte dev créé, clés prêtes, tier avec quota suffisant.
- **RevenueCat** : comptes dev Apple + Google validés avant Sprint 3.
- **Cloudflare Worker** : compte + domaine configuré avant Sprint 1.
- **PostHog** : compte EU créé avant Sprint 3.
- **Apple Developer Program** : 99 $/an, validation identité (2-3j).
- **Google Play Console** : 25 $ one-time, validation identité (quelques heures).

---

## Definition of Done (par story)

Pour considérer une story terminée :
- [ ] Code implémenté et commité (conventional commits).
- [ ] `flutter analyze` clean, 0 warning.
- [ ] Tests unitaires écrits sur la logique domaine + passent.
- [ ] `flutter test` passe en CI.
- [ ] Tests manuels sur device iOS + Android réels (ou 1 si feature Android-only / iOS-only).
- [ ] Acceptance criteria de la story validés.
- [ ] Si décision technique diverge de l'archi : ADR committé dans `docs/adr/`.
- [ ] Story marquée `completed` dans `docs/sprint-status.yaml`.

**DoD pour un sprint entier :**
- [ ] Toutes stories Must Have du sprint en `completed`.
- [ ] Démo interne (Clement self-demo) validée.
- [ ] Velocity réelle enregistrée dans `docs/sprint-status.yaml` pour ajustement sprint suivant.

---

## Next Steps

### Immédiat

1. **Week 0 — Jalon 0** : Démarrer STORY-J00 aujourd'hui hors codebase Flutter.
2. Créer les comptes dev manquants (Apple, Google, RevenueCat, PostHog, Cloudflare) en parallèle.
3. Si Jalon 0 validé : démarrer Sprint 1.

### Commandes BMAD

- `/bmad:create-story STORY-000` → générer un doc story détaillé pour le scaffolding.
- `/bmad:dev-story STORY-000` → implémenter directement (recommandé).
- Itérer sur chaque story du sprint.

### Cadence de sprint

- **Sprint length :** 2 semaines.
- **Kick-off :** lundi semaine 1.
- **Revue + rétro :** vendredi semaine 2 (solo, ~30 min self-review).
- **Replan :** ajuster le sprint suivant selon la velocity mesurée.

---

**Document créé avec BMAD Method v6 — Phase 4 (Implementation Planning)**

*Prochaine étape : `/bmad:create-story` ou `/bmad:dev-story` pour commencer.*
