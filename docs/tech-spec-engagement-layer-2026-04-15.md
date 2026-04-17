# Tech Spec — Engagement Layer ("Beedle's Voice")

**Date** : 2026-04-15
**Project level** : 1 (7 stories, ~4 jours de dev solo)
**Related docs** : [`brainstorming-engagement-layer-2026-04-15.md`](./brainstorming-engagement-layer-2026-04-15.md) · [`DESIGN.md`](./DESIGN.md) · [`architecture-beedle-2026-04-15.md`](./architecture-beedle-2026-04-15.md)

---

## 1. Problem & Solution

**Problem :** Beedle est une app read-it-later. Le risque mortel connu de cette catégorie : les cards capturées finissent en cimetière. L'user ouvre l'app une fois, ingère 10 screenshots, puis revient jamais. La rétention s'effondre.

**Solution :** **Beedle's Voice** — une couche d'engagement où une voix IA cohérente (persona implicite, sans mascotte) s'exprime à partir des cards ingérées, sur 2 surfaces :
- **Terminal Card** sur la Home : widget monospace dark inverse qui affiche un message observationnel sur le dernier contenu capturé.
- **Push Notifications** contextuelles : name-dropent l'auteur de la card, deep-link vers elle.

**Architectural leverage clé :** les messages sont **pré-générés par le LLM au moment de la digestion de la card** (un appel, pas deux). On ajoute 2 champs au JSON schema — coût marginal ~50 tokens output. Pas de cron, pas d'agent séparé.

---

## 2. Requirements

### Fonctionnels (F)

- **F1 — Extension digestion LLM** : chaque card digérée produit en plus `engagementMessages[]` (3-6 items : content ≤ 120 chars, type ∈ {reminder, invite, observation, connection, reflection}, format ∈ {short, long}, delayDays ∈ [0, 30]). Stockés ObjectBox.
- **F2 — Terminal Card widget** : affiché sur Home sous le Suggestion Hero (et au-dessus de "Toutes tes fiches"). Monospace (Geist Mono), fond ink `#0A0A0A`, texte neutral.1 `#F8F4ED`, 4 lignes visibles, historique fade-up (opacity decreasing). Nouveau message arrive avec typing animation (24ms/char). Tap → drawer bottom sheet avec historique complet.
- **F3 — Scheduler service** : sélectionne le message à afficher sur Home au boot + toutes les 4h quand l'app est en foreground. Règles de pick : (a) priorité aux messages `delayDays ≤ age_days` non encore `shownAt`, (b) varier les types sur une journée, (c) jamais 2 messages de la même card consécutifs.
- **F4 — Push notifications** : `flutter_local_notifications` programme 1 push/jour max (configurable 0-3). Créneaux 8h00 ou 20h00 selon heuristique (user plus actif le matin ou le soir). Body = message.content. Title = "Beedle". Deep-link → `CardDetailRoute(uuid: cardUuid)`.
- **F5 — Back-off absence** : aucun push entre 22h00-8h00 local. Si `lastAppOpen > 3 jours` → pause des push jusqu'au prochain open manuel.
- **F6 — Settings → Voice** : nouvelle sub-section dans Settings avec 4 contrôles : toggle "Terminal Card on Home", toggle "Push notifications", slider quota push/jour (0-3), toggle "Zen mode" (désactive tout).
- **F7 — Onboarding intégration** : remplacer l'étape 7 "notifications permission" existante par un step qui présente le Voice (1 phrase explicative + demande permission OS push + opt-in par défaut).

### Non-fonctionnels (NF)

- **NF1 — Coût LLM** : overhead ≤ 100 tokens output / digestion (mesurer sur 10 digestions avant merge).
- **NF2 — Perf** : Terminal Card ne doit pas ajouter > 50ms au rendu Home. Typing animation via `TickerProvider`, pas de setState par frame.
- **NF3 — Accessibility** : `Semantics` label sur Terminal Card ("message from Beedle, latest: ..."). Toutes les actions (expand, dismiss) accessibles en VoiceOver.
- **NF4 — Respect** : jamais plus de 1 push/jour par défaut. Respect `DND` / Focus mode (natif iOS). Quota hard-capped à 3 même si bug.
- **NF5 — CalmSurface compliance** : Terminal Card respecte §2 Signature Patterns + anti-patterns §6 (pas d'emoji, pas de gradient sur texte, pas de glow). Voir DESIGN.md.

### Out of scope (explicite)

- ❌ Chat bidirectionnel / input utilisateur dans le Terminal Card (read-only strict).
- ❌ Génération de messages on-the-fly au boot (tout est batch à l'ingestion).
- ❌ Weekly Digest exportable (noté comme ouverture, pas ce sprint).
- ❌ Pattern analytics ("tu captures 80% en soirée") — ouverture, pas ce sprint.
- ❌ Sound / haptic sur arrivée de message.
- ❌ Widget home iOS / complication watch (long-term roadmap).
- ❌ Migration des cards existantes : nouveau prompt utilisé uniquement sur les nouvelles ingestions. Les anciennes cards n'auront pas de `engagementMessages` — fallback gracieux (Terminal Card affiche une observation générique basée sur le titre/tags).

---

## 3. Technical Approach

### 3.1 Tech stack (existant, pas de nouvelle dépendance)

- **Flutter** ≥ 3.27.0, Dart 3.10+
- **State management** : Riverpod 3 + riverpod_generator
- **Navigation** : AutoRoute 11
- **Local DB** : ObjectBox 5 (ajout d'une table `EngagementMessage`)
- **Immutabilité** : Freezed 3 (nouvelle entity + extension DigestionResult)
- **LLM** : OpenAI gpt-4o-mini via Worker Cloudflare (existant, system prompt étendu)
- **Notifications** : `flutter_local_notifications ^21.0.0` (déjà dans pubspec, pas utilisé encore)
- **Fonts** : Geist Mono (déjà câblé via google_fonts)
- **Design tokens** : CalmSurface (`calm_tokens.dart`)

### 3.2 Architecture (delta sur l'existant)

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation                                                │
│  ┌────────────────────┐   ┌─────────────────────────────┐   │
│  │ HomeScreen         │   │ SettingsScreen              │   │
│  │  • Greeting        │   │  • (existing sections)      │   │
│  │  • Suggestion Hero │   │  • VoiceSection (NEW)       │   │
│  │  • TerminalCard ◄──┼──┐│    - toggleTerminal         │   │
│  │  • Toutes fiches   │  ││    - togglePush             │   │
│  └────────────────────┘  ││    - sliderQuota 0-3        │   │
│                          ││    - toggleZen              │   │
│                          │└─────────────────────────────┘   │
│                          │                                  │
│                          │  ┌────────────────────────────┐  │
│                          └──┤ EngagementHomeViewModel    │  │
│                             │ (watches pool, picks msg)  │  │
│                             └──────┬─────────────────────┘  │
└────────────────────────────────────┼───────────────────────┘
                                     │
┌────────────────────────────────────┼───────────────────────┐
│ Domain                             ▼                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ EngagementSchedulerService                           │  │
│  │  • nextMessageForHome()                              │  │
│  │  • scheduleUpcomingPushes()                          │  │
│  │  • markShown(messageUuid)                            │  │
│  └──────────┬──────────────────────────────────┬────────┘  │
│             │                                  │           │
│  ┌──────────▼────────────┐    ┌────────────────▼────────┐  │
│  │ EngagementMessage     │    │ NotificationService     │  │
│  │ Repository            │    │  (interface)            │  │
│  └──────────┬────────────┘    └──────────┬──────────────┘  │
└─────────────┼──────────────────────────────┼──────────────┘
              │                              │
┌─────────────┼──────────────────────────────┼──────────────┐
│ Data        ▼                              ▼              │
│  ┌────────────────────────┐   ┌─────────────────────────┐ │
│  │ EngagementMessage      │   │ NotificationService     │ │
│  │ LocalDataSource (OBX)  │   │ Impl (flutter_local_    │ │
│  └────────────────────────┘   │ notifications wrapper)  │ │
│                                └─────────────────────────┘ │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ LLMRepositoryImpl (EXTENDED)                         │  │
│  │  • _systemPrompt → add Engagement generation rules   │  │
│  │  • _jsonSchema → add engagementMessages[] field      │  │
│  │  • _parseDigestion → extract EngagementMessage list  │  │
│  └──────────┬───────────────────────────────────────────┘  │
│             │                                              │
│  ┌──────────▼───────────────────────────────────────────┐  │
│  │ IngestionPipelineService (EXTENDED)                  │  │
│  │  After card upsert → persist engagementMessages      │  │
│  │                    → call scheduler.scheduleUpcoming │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

### 3.3 Data model

#### Nouvelle entity `EngagementMessage` (domain)

```dart
@freezed
abstract class EngagementMessageEntity with _$EngagementMessageEntity {
  const factory EngagementMessageEntity({
    required String uuid,
    required String cardUuid,           // ref CardEntity.uuid
    required String content,            // ≤ 120 chars
    required EngagementMessageType type,
    required EngagementMessageFormat format, // short | long
    required int delayDays,             // 0..30
    required DateTime createdAt,
    DateTime? scheduledAt,              // populated when picked for push
    DateTime? shownAt,                  // populated when displayed
  }) = _EngagementMessageEntity;
}

enum EngagementMessageType { reminder, invite, observation, connection, reflection }
enum EngagementMessageFormat { short, long }
```

#### ObjectBox model

```dart
@Entity()
class EngagementMessageLocalModel {
  @Id()
  int id;

  @Index() @Unique()
  String uuid;

  @Index()
  String cardUuid;

  String content;
  String type;      // enum.name
  String format;    // enum.name
  int delayDays;
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? scheduledAt;

  @Property(type: PropertyType.date)
  DateTime? shownAt;
}
```

Index sur `cardUuid` et `scheduledAt` (pour les queries "upcoming").

#### Extension LLM JSON schema

Ajout dans `_jsonSchema()` :
```json
{
  "engagementMessages": {
    "type": "array",
    "minItems": 3, "maxItems": 6,
    "items": {
      "type": "object",
      "required": ["content", "type", "format", "delayDays"],
      "additionalProperties": false,
      "properties": {
        "content":   { "type": "string", "maxLength": 120 },
        "type":      { "type": "string", "enum": ["reminder", "invite", "observation", "connection", "reflection"] },
        "format":    { "type": "string", "enum": ["short", "long"] },
        "delayDays": { "type": "integer", "minimum": 0, "maximum": 30 }
      }
    }
  }
}
```

Et l'ajout équivalent dans `required` du parent schema.

#### Extension system prompt (résumé)

Section à ajouter au prompt existant :

> **## Field `engagementMessages`**
>
> Generate 3-6 micro-messages that Beedle's voice can surface later (terminal card + push notifications). These messages must:
>
> - Be observational, present tense, never exclamatory, never emoji.
> - Tutoyer (French) or use 'you' (English).
> - Name-drop the author/source when detected ("Sthiven's prompt", "D'après Guillaume").
> - Respect format length: `short` ≤ 40 chars (for push), `long` ≤ 120 chars (for terminal).
> - Vary types: at least 1 reminder, 1 invite, and 1 other type per card.
> - `delayDays`: 0 = same-day surfacing, 3 = re-engagement, 7 = test prompt, 14 = reflection, 30 = rediscovery.
> - NEVER culpabilisant ("tu n'as pas...", "you forgot..."). Tone = Apple narrator, not Duolingo.

### 3.4 Notification service

Wrapper mince sur `flutter_local_notifications`. API domain :

```dart
abstract interface class NotificationService {
  Future<bool> requestPermission();
  Future<void> scheduleOne({
    required String uuid,
    required String body,
    required DateTime at,
    required String cardUuid, // pour deep-link payload
  });
  Future<void> cancel(String uuid);
  Future<void> cancelAll();
}
```

Le payload JSON contient `{"cardUuid": "..."}`, lu au démarrage de l'app par un handler qui push la route `CardDetailRoute(uuid)`.

---

## 4. Stories (plan d'implémentation)

Ordre recommandé, chaque story ≈ 0.5-1 jour.

### Story 1 — Data layer `EngagementMessage`
Entity Freezed + ObjectBox model + DataSource interface + impl + Repository interface + impl + Mapper + generated code (`build_runner`). Tests unitaires mapper + repo impl.

### Story 2 — Extension LLM digestion
Update `_systemPrompt()` + `_jsonSchema()` dans `LLMRepositoryImpl`. Étendre `DigestionResultEntity` avec `engagementMessages: List<EngagementMessageEntity>`. Update `_parseDigestion()`. Update `IngestionPipelineService._processJob()` pour persister la liste après l'upsert de la card. **Validation NF1** : mesurer le delta tokens sur 10 digestions, logger dans `BUILD_LOG.md`.

### Story 3 — `EngagementSchedulerService`
Domain service. 3 méthodes :
- `Future<EngagementMessageEntity?> nextMessageForHome()` — pick selon règles F3
- `Future<void> scheduleUpcomingPushes(UserPreferences prefs)` — programme les N prochaines push selon quota + back-off
- `Future<void> markShown(String uuid)` — flag shownAt = now
Tests unitaires avec ObjectBox in-memory + mocks.

### Story 4 — `NotificationService`
Interface + impl wrappant `flutter_local_notifications`. Init dans `bootstrap.dart`. Handler `onDidReceiveNotificationResponse` → push `CardDetailRoute`. Demande permission iOS/Android. Tests de smoke.

### Story 5 — Terminal Card widget
Nouveau widget `lib/presentation/widgets/terminal_card.dart`. Specs :
- `GlassCard` variant : `backgroundColor: AppColors.ink`, `borderColor: neutral7`, blurSigma: 12, cornerRadius: CalmRadius.xl2
- `content: TextStyle(fontFamily: GeistMono, color: neutral.1, fontSize: 13, height: 1.5)`
- Typing animation : `AnimationController` + builder qui révèle N chars
- History fade : 3 messages précédents, opacities [0.4, 0.25, 0.12]
- Tap → `showModalBottomSheet` avec full history (glass blur σ 24)
- State via Riverpod provider `terminalMessageProvider` qui watche `EngagementSchedulerService.nextMessageForHome()`

### Story 6 — Home integration
Insérer `TerminalCard` dans `home.screen.dart` entre `_SuggestionHero` et la section "Toutes tes fiches". Invalidate sur arrival de nouvelle card (via `cardGeneratedStream`).

### Story 7 — Settings → Voice + Onboarding step
Sub-section Settings avec 4 contrôles (F6). Update `UserPreferencesEntity` avec `voiceSettings: VoiceSettings { terminalEnabled, pushEnabled, pushQuotaPerDay, zenMode }`. Re-câbler `scheduleUpcomingPushes` sur changement de prefs.

Update onboarding step 7 (permissions) pour intégrer demande notification via nouveau `NotificationService`.

---

## 5. Acceptance Criteria

- [ ] AC1 — Un nouveau screenshot importé génère 3-6 `EngagementMessage` visibles dans la DB (vérifier via test manuel ou log)
- [ ] AC2 — Le Terminal Card apparaît sur Home, affiche 1 message lisible, tap expand l'historique
- [ ] AC3 — Typing animation fluide (≥ 55fps en mode profile)
- [ ] AC4 — 1 push schedulée apparaît réellement sur l'iPhone au créneau prévu
- [ ] AC5 — Tap sur la push ouvre l'app sur la `CardDetailRoute` correcte
- [ ] AC6 — Settings → Voice : toggle push OFF → aucune push ne part ; quota slider 0 → idem ; Zen mode ON → Terminal + push off
- [ ] AC7 — Back-off : forcer `lastAppOpen > 3j` (via outil dev) → pas de push programmée
- [ ] AC8 — Onboarding step permission fonctionne, opt-in par défaut
- [ ] AC9 — Coût LLM mesuré : ≤ 100 tokens output additionnels (NF1 validé)
- [ ] AC10 — `flutter analyze` : 0 erreur
- [ ] AC11 — DESIGN.md checklist CalmSurface-ready §8 : 100% coché sur le Terminal Card
- [ ] AC12 — Aucun push entre 22h-8h quand test avec horloge système décalée

---

## 6. Non-Functional Requirements

Couverts en §2 (NF1-NF5). Récap :

- **Perf** : overhead LLM ≤ 100 tokens output, Home render ≤ +50ms
- **Respect** : quota 1/j par défaut, back-off 3j absence, DND respecté, aucune push 22h-8h
- **A11y** : `Semantics` labels sur Terminal Card, actions VoiceOver
- **CalmSurface** : 0 emoji, 0 gradient sur texte, 0 glow — checklist §8 du DESIGN.md à 100%

---

## 7. Dependencies & Risks

### Dependencies

- `flutter_local_notifications ^21.0.0` — déjà dans pubspec, pas utilisé jusqu'ici
- Permission notification iOS/Android — demande via `NotificationService.requestPermission()` dans onboarding
- Worker Cloudflare — doit accepter le nouveau schema (pas de changement côté Worker, c'est juste un JSON plus gros renvoyé par OpenAI)
- ObjectBox generator — re-run `build_runner build` après ajout de `EngagementMessageLocalModel`

### Risks & mitigations

- **Risk 1** : OpenAI ne respecte pas bien le prompt → messages incohérents / culpabilisants
  - **Mitigation** : few-shot examples dans le system prompt + validation côté Dart (trim, length check, rejet si pattern "you forgot" / "tu n'as pas"). Fallback sur un pool statique de 5 messages génériques si parsing échoue.
- **Risk 2** : Coût tokens explose au-delà de 100 tokens
  - **Mitigation** : mesure early (story 2) + optionnel de baisser `maxItems` de 6 à 4 si nécessaire.
- **Risk 3** : Push notifications bloquées par l'user en onboarding → feature dégradée
  - **Mitigation** : Terminal Card reste fonctionnel sans push (découplé). Communication claire dans l'onboarding step.
- **Risk 4** : ObjectBox migration `build_runner` casse la DB existante des testeurs alpha
  - **Mitigation** : ObjectBox gère les ajouts de table/champs sans migration. Mais tester sur un device avec DB pré-existante avant release.
- **Risk 5** : DND / Focus mode iOS 16+ bloque silencieusement les notifs → pas de retour user
  - **Mitigation** : accepter. Les users en DND ne veulent pas être dérangés — c'est le bon comportement. On log côté `NotificationService` les tentatives de fire pour debug.
- **Risk 6** : Anciennes cards (sans `engagementMessages`) créent un Terminal Card vide
  - **Mitigation** : fallback gracieux — si pool vide, le Terminal Card affiche un message système générique ("standby. capture something.") ou se hide.

### Timeline

- **Target completion** : ~4 jours de dev solo (7 stories × 0.5-1j) + 1 jour QA/release → **~1 semaine**
- **Milestones** :
  - **M1** (fin J2) : Data + LLM extension + scheduler — le backend produit et stocke les messages (non visible UI)
  - **M2** (fin J3) : Terminal Card visible sur Home avec messages réels
  - **M3** (fin J4) : Push notifications opérationnelles + Settings → Voice
  - **M4** (fin J5) : Onboarding mis à jour + QA pass + flutter analyze 0 erreur + AC 100% coché
  - **M5** (J6-7) : Buffer pour bugs, release TestFlight/Play internal

---

## 8. Validation checklist

- [x] Problem and solution are clear
- [x] Requirements specifiques et testables (F1-F7, NF1-NF5)
- [x] Tech stack défini (aucune nouvelle dépendance, tout dans l'existant)
- [x] Stories découpées (7 stories, 0.5-1j chacune)
- [x] Acceptance criteria concrets (12 AC vérifiables)
- [x] Out of scope explicite (6 items)
- [x] Risks identifiés + mitigations (6 risques)
- [x] Timeline réaliste (~1 semaine)

---

*Generated by BMAD Method v6 — Product Manager (Tech Spec workflow)*
