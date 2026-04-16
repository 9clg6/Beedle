# ✨ feat: Onboarding Questionnaire Refactor

**Type** : enhancement (refactor majeur)
**Priorité** : haute (MVP v1, avant launch public)
**Owner** : Clement (solo dev)
**Status** : plan ready — awaiting `/vgv-wingspan:build`
**Date** : 2026-04-16
**Brainstorm source** : [`docs/onboarding-questionnaire-blueprint-2026-04-16.md`](../onboarding-questionnaire-blueprint-2026-04-16.md) (refiné)

---

## 1. Summary

Remplacer l'onboarding 12-étapes actuel de Beedle par un flow 15-écrans
questionnaire-style inspiré Noom/Headspace/Duolingo, conçu pour maximiser
l'investissement psychologique avant paywall et déclencher un moment viral
export-PNG à la fin. Refactorise 5 widgets inline en 12 fichiers dédiés,
étend le state avec 2 enums, câble RevenueCat au paywall, et logue un
event PostHog `onboarding_completed`.

## 2. Motivation

**Problème actuel** : l'onboarding existant est **linéaire et pauvre en
investissement** (5 écrans hero "texte uniquement" suivis d'un quiz à 3
champs, des permissions sèches, un paywall incomplet). Le bouton
*"Continuer en plan gratuit"* a un `onPressed: () {}` vide (bug déjà
diagnostiqué dans la session précédente). Aucun moment viral, aucun
social proof, aucune démo interactive — la conversion paywall s'appuie
uniquement sur la tagline et la présomption que l'user comprendra la
valeur sans la vivre.

**Opportunité** : aligner sur le playbook éprouvé des apps consumer
subscription (Noom, Headspace, Duolingo) — self-discovery → social
proof → bridge → preferences → permissions primées → processing → demo
interactif → viral moment → paywall. Le user a **déjà construit quelque
chose** (ses 3 fiches digérées) au moment du paywall : sunk cost
psychologique qui maximise la conversion.

**Pourquoi maintenant** : le MVP est stabilisé (pipeline OCR + LLM + card
progression + permissions fixées + app icon Dot-b), il manque **le seul
composant orienté conversion** pour préparer le launch stores.

## 3. Acceptance Criteria

### Fonctionnel

- [ ] Fresh install → flow 15 écrans complet jusqu'à la Home (avec ou sans achat)
- [ ] Validation par écran : CTA *Continuer* grisé tant que l'input minimum n'est pas rempli (goal/pain/categories/demo)
- [ ] Back/forward preserve le state (retour sur Goal conserve la sélection)
- [ ] "Plus tard" sur photos/notifs → flow continue sans crash, permissions restent `denied` dans le state
- [ ] Viral moment : share bouton génère un PNG de la stack de 3 fiches + ouvre le native share sheet iOS+Android
- [ ] Paywall : *Commencer mon essai* déclenche `Purchases.purchasePackage()` → sur succès → `finishOnboarding()` → `HomeRoute`
- [ ] Paywall : *Continuer en gratuit* → `finishOnboarding()` → `HomeRoute` (pas `onPressed: () {}` vide)
- [ ] Paywall : *Restaurer mes achats* → `Purchases.restorePurchases()` → Home si entitlement actif
- [ ] `finishOnboarding()` persiste `UserPreferencesEntity.onboardingCompletedAt` + log PostHog `onboarding_completed` avec payload (goal, pain_points_count, categories, teaser_count, grants, demo_picked_count)

### Non-fonctionnel

- [ ] Existant préservé (pas de régression) : permissions Podfile macros iOS, Darwin init no-prompt-at-boot, UploadProgressCard sans BackdropFilter, Dot-b icon + splash, prod worker URL
- [ ] Navigation : NavBar masquée sur Welcome/Processing/Viral (3 full-immersion), visible + validator sur les 12 autres
- [ ] Accessibility V1 : `Semantics` sur les tappables clés, smoke test VoiceOver iOS + TalkBack Android OK sur écrans Goal/Permission Photos/Paywall
- [ ] Traductions FR complètes (~70 clés) · EN = copy FR + marqueurs `// TODO-TRANSLATE` (fallback easy_localization sur FR)
- [ ] `flutter analyze` → 0 error, 0 warning sur les fichiers nouveaux/modifiés
- [ ] `dart format` → 100 %
- [ ] Build iOS + Android OK en release mode

## 4. Technical Specification

### 4.1. Architecture impact

**Couche concernée** : `presentation` (onboarding feature) principalement,
avec quelques touches domain (nouveaux enums) et data (asset
`cards.json`).

**Pas d'impact** sur : pipeline OCR/LLM, ingestion jobs, repository des
cards, notifications scheduling, gamification. Le refactor est **isolé**
à la feature onboarding.

**Diagram du flow** :

```
SplashScreen
   └─ prefs.hasCompletedOnboarding ?
        ├─ true  → HomeRoute
        └─ false → OnboardingRoute
                    └─ OnboardingScreen
                         └─ PageView(15)
                              ├─ 01 Welcome [immersion]
                              ├─ 02-04 Self-discovery [NavBar + validator]
                              ├─ 05-07 Social + Bridge [NavBar]
                              ├─ 08-09 Preferences [NavBar]
                              ├─ 10-11 Permissions [NavBar]
                              ├─ 12 Processing [immersion, auto-advance 2s]
                              ├─ 13 Demo [NavBar, validator: ≥3 swipes]
                              ├─ 14 Viral [immersion]
                              └─ 15 Paywall [NavBar]
                                   ├─ Purchases.purchasePackage() → HomeRoute
                                   └─ "Continuer en gratuit" → finishOnboarding → HomeRoute
```

### 4.2. Fichiers touchés

#### Nouveaux fichiers (17)

- `lib/domain/enum/onboarding_goal.enum.dart`
- `lib/domain/enum/pain_point.enum.dart`
- `lib/domain/entities/onboarding_sample_card.entity.dart` (+ `.freezed.dart` + `.g.dart` code-gen)
- `lib/features/onboarding/presentation/screens/onboarding_step_validator.dart`
- `lib/features/onboarding/presentation/widgets/ob_welcome_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_goal_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_pain_points_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_tinder_step.dart` (+ `ob_swipe_card.dart`)
- `lib/features/onboarding/presentation/widgets/ob_social_proof_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_solution_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_comparison_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_category_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_reminder_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_permission_photos_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_permission_notifs_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_processing_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_demo_step.dart` (+ `demo_sample_card.dart`)
- `lib/features/onboarding/presentation/widgets/ob_viral_moment_step.dart` (+ `_OnboardingPreviewCard` + helper export PNG)
- `lib/features/onboarding/presentation/widgets/ob_paywall_step.dart`
- `assets/onboarding/home-preview.png` (placeholder + `TODO-USER`)
- `assets/onboarding/samples/sample-prompt-eval.png` (placeholder)
- `assets/onboarding/samples/sample-claude-code-skills.png` (placeholder)
- `assets/onboarding/samples/sample-figma-autolayout.png` (placeholder)
- `assets/onboarding/samples/sample-dart-async.png` (placeholder)
- `assets/onboarding/samples/sample-raycast-cmd.png` (placeholder)
- `assets/onboarding/samples/cards.json`

#### Fichiers modifiés (7)

- `lib/features/onboarding/presentation/screens/onboarding.state.dart` — étendu : new fields (goal, painPoints, tinderAgreedIndices, demoSwipedRightIndices)
- `lib/features/onboarding/presentation/screens/onboarding.view_model.dart` — nouvelles méthodes selectGoal/togglePainPoint/recordTinderSwipe/recordDemoSwipe + adjustement next/previous/goTo pour 15 pages
- `lib/features/onboarding/presentation/screens/onboarding.screen.dart` — refonte **complète** : remove inline widgets `_OBHero`, `_OBQuizStep`, `_OBPermissionStep`, `_OBPaywallStep`, `_OBAhaStep`; remplace par 15-page PageView + NavBar conditionnelle
- `assets/translations/fr.json` — ~70 nouvelles clés sous `onboarding.*`
- `assets/translations/en.json` — mêmes clés avec FR values + `// TODO-TRANSLATE`
- `lib/generated/locale_keys.g.dart` — régénéré (patch manuel si build_runner refuse comme précédemment)
- `pubspec.yaml` — ajout `share_plus: ^10.0.0` + section `flutter.assets` étendue

### 4.3. Changements data model

```dart
// lib/domain/enum/onboarding_goal.enum.dart
enum OnboardingGoal {
  buildFaster,
  stayAIUpToDate,
  rememberTutorials,
  findInfoFast,
  shareWithTeam,
  exploring,
}

// lib/domain/enum/pain_point.enum.dart
enum PainPoint {
  pelliculeCemetery,
  reGoogle,
  notionHeavy,
  neverRevisit,
  forgetWhatIKnow,
  noTimelyReminder,
  llmMissOut,
}

// lib/domain/entities/onboarding_sample_card.entity.dart
@freezed
class OnboardingSampleCard with _$OnboardingSampleCard {
  const factory OnboardingSampleCard({
    required String title,
    required String summary,
    required String actionLabel,
    required String intent,        // "apply" | "read" | "reference"
    required List<String> tags,
  }) = _OnboardingSampleCard;
  factory OnboardingSampleCard.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSampleCardFromJson(json);
}

// lib/features/onboarding/presentation/screens/onboarding.state.dart (ÉTENDU)
@Freezed(copyWith: true)
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentIndex,
    // Self-discovery (NEW)
    OnboardingGoal? goal,
    @Default(<PainPoint>{}) Set<PainPoint> painPoints,
    @Default(<int>{}) Set<int> tinderAgreedIndices,
    // Demo (NEW)
    @Default(<int>{}) Set<int> demoSwipedRightIndices,
    // Preferences (existing — unchanged)
    @Default(<ContentCategory>[]) List<ContentCategory> contentCategories,
    @Default(1) int teaserCountPerDay,
    @Default(20) int captureReminderHour,
    // Permissions (existing — unchanged)
    @Default(false) bool notificationsGranted,
    @Default(false) bool photosGranted,
    // Submission (existing — unchanged)
    @Default(false) bool isSubmitting,
  }) = _OnboardingState;
  factory OnboardingState.initial() => const OnboardingState();
}
```

**Note** : les nouveaux champs du state **ne sont PAS persistés** dans
`UserPreferencesEntity` — ils ne vivent que le temps de la session
d'onboarding et sont loggués à PostHog au `finishOnboarding()`.

### 4.4. Dépendances

**Nouvelle** :

```yaml
dependencies:
  share_plus: ^10.0.0
```

**Déjà présentes (réutilisées)** :
- `purchases_flutter: ^9.16.1` — câblage RevenueCat au paywall
- `permission_handler: ^11.3.1` — déjà utilisé pour photos
- `flutter_local_notifications: ^21.0.0` — notifs
- `freezed ^3.2.3` + `json_serializable ^6.8.0` — DTO code-gen
- `flutter_riverpod ^3.1.0` + `riverpod_annotation ^4.0.0` — state
- `google_fonts ^6.2.1` — Hanken Grotesk
- `figma_squircle ^0.6.3` — GlassCard shapes
- `easy_localization ^3.0.5` — traductions
- `posthog_flutter ^5.23.1` — event onboarding_completed

### 4.5. Assets spec

- **PNG samples** : ratio 9:16, **1080 × 1920 px**, PNG 8-bit, < 300 KB (compression via pngquant/tinypng à la main)
- **home-preview.png** : même ratio, capture via `flutter screenshot` sur une Home peuplée OU mockup Figma
- **cards.json** : 3 entrées minimum, `OnboardingSampleCard.fromJson` compatible

Tous les PNG créés **en placeholder vide** dans le commit initial (`TODO-USER` pour remplacer par les vrais).

---

## 5. Implementation Plan — 10 commits atomiques

Chaque commit est **auto-contenu** (`flutter analyze` clean, pas de dépendance
forward). L'ordre garantit que `flutter build` fonctionne à chaque étape.

### Commit 1 — `feat(onboarding): add domain enums and state extension`

**Files** :
- `lib/domain/enum/onboarding_goal.enum.dart` — NEW
- `lib/domain/enum/pain_point.enum.dart` — NEW
- `lib/domain/entities/onboarding_sample_card.entity.dart` — NEW
- `lib/features/onboarding/presentation/screens/onboarding.state.dart` — extend
- `lib/features/onboarding/presentation/screens/onboarding.view_model.dart` — add methods
- `pubspec.yaml` — `share_plus: ^10.0.0`

**Actions** :
1. Write enum files (simple `enum { … }` — pas de code-gen)
2. Write `OnboardingSampleCard` avec `@freezed` + `@JsonSerializable`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Extend `OnboardingState` (nouveaux fields)
5. Regen freezed
6. Add ViewModel methods : `selectGoal`, `togglePainPoint`, `recordTinderSwipe`, `recordDemoSwipe`
7. Adjust `next()`: cap à index 14 (au lieu de 11)
8. `flutter pub get` + `flutter analyze` → clean

**Test manual** : `flutter run` → onboarding existant toujours fonctionne (on n'a pas encore touché le screen).

### Commit 2 — `chore(assets): scaffold onboarding samples folder + cards.json`

**Files** :
- `assets/onboarding/home-preview.png` — NEW (placeholder 1x1 transparent PNG)
- `assets/onboarding/samples/sample-prompt-eval.png` — placeholder
- `assets/onboarding/samples/sample-claude-code-skills.png` — placeholder
- `assets/onboarding/samples/sample-figma-autolayout.png` — placeholder
- `assets/onboarding/samples/sample-dart-async.png` — placeholder
- `assets/onboarding/samples/sample-raycast-cmd.png` — placeholder
- `assets/onboarding/samples/cards.json` — 3 entries réelles (du blueprint §14)
- `pubspec.yaml` — section flutter.assets étendue

**Actions** :
1. Crée un 1×1 PNG transparent (via `dart:io` script one-liner ou juste `touch` + `convert` si ImageMagick dispo)
2. Write `cards.json` avec les 3 exemples du blueprint
3. Update pubspec
4. `// TODO-USER` comments à chaque placeholder PNG qu'il faut remplacer avant launch

**Test manual** : `flutter run` → assets chargent sans erreur.

### Commit 3 — `feat(i18n): add onboarding translation keys`

**Files** :
- `assets/translations/fr.json` — ~70 keys ajoutées
- `assets/translations/en.json` — mêmes keys, valeur FR copiée + `// TODO-TRANSLATE`
- `lib/generated/locale_keys.g.dart` — patch manuel (build_runner easy_localization a casé par le passé)

**Actions** :
1. Extend `fr.json` avec les clés (convention dans blueprint §4.7 raffiné)
2. Copier dans `en.json` avec valeur FR + marqueur
3. Patcher `locale_keys.g.dart` manuellement (ajouter ~70 `static const ... = '...';`)
4. Compiler → pas d'erreur sur les `LocaleKeys.xxx.tr()` utilisés en commit ultérieurs

**Test manual** : N/A (pas encore utilisé)

### Commit 4 — `feat(onboarding): navigation scaffolding with conditional NavBar`

**Files** :
- `lib/features/onboarding/presentation/screens/onboarding_step_validator.dart` — NEW
- `lib/features/onboarding/presentation/screens/onboarding.screen.dart` — gros refactor :
  - Remove old inline widgets (`_OBHero`, `_OBQuizStep`, `_OBPermissionStep`, `_OBPaywallStep`, `_OBAhaStep`)
  - Remplace par 15 `Placeholder()` ou widgets minimum viables
  - Implement `_fullImmersionSteps = {0, 11, 13}`
  - Conditional NavBar
  - `_NavBar` lit `OnboardingStepValidator.canAdvance(index, state)` pour gate Next
  - Ajuste `total: 15` dans `CalmSegmentedProgress`

**Actions** :
1. Create `OnboardingStepValidator` (static method simple)
2. Refactor `onboarding.screen.dart` :
   - PageView de 15 children — tous `Container(child: Text('Screen $i'))` pour commencer
   - NavBar conditionnelle
3. Vérifier que forward/back fonctionne avec Validator grisé/enabled selon les indices triviaux (2 = goal null → grisé)

**Test manual** : `flutter run` → swipe manuel index 0-14 fonctionne, NavBar visible/masquée selon step, Continuer grisé quand applicable.

### Commit 5 — `feat(onboarding): hook + self-discovery screens (01-04)`

**Files** (NEW) :
- `lib/features/onboarding/presentation/widgets/ob_welcome_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_goal_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_pain_points_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_tinder_step.dart`
- `lib/features/onboarding/presentation/widgets/ob_swipe_card.dart`

**Files modifiés** :
- `onboarding.screen.dart` — remplace `Placeholder` des indices 0-3 par les vrais widgets

**Actions** :
1. Write Welcome avec `Image.asset('assets/onboarding/home-preview.png')` + CTA + eyebrow doto
2. Write Goal avec 6 options GlassCard single-select → `selectGoal(goal)`
3. Write PainPoints avec 7 options multi-select checkbox → `togglePainPoint(p)`
4. Write Tinder :
   - `Stack` de 3 cards visibles, la top card `Dismissible` avec `direction: horizontal`
   - `onDismissed: (direction) → recordTinderSwipe(idx, agreed: dir == DismissDirection.startToEnd)` + `setState(() => currentCardIndex++)`
   - Progression `3/5`
   - Auto-advance via `ref.read(...).next()` quand `currentCardIndex == 5`
5. Wire dans PageView

**Test manual** : flow complet 00 → 03 fluide, state Riverpod persiste si on back/forward.

### Commit 6 — `feat(onboarding): social proof + bridge screens (05-07)`

**Files** (NEW) :
- `ob_social_proof_step.dart` — 3 testimonials GlassCards (hardcodés TODO-USER)
- `ob_solution_step.dart` — 4 pain→fix pairs avec icônes ember
- `ob_comparison_step.dart` — 2 cards stack verticales (pas table)

**Test manual** : texte visible, design aligne DESIGN.md.

### Commit 7 — `feat(onboarding): preference screens (08-09)`

**Files** (NEW) :
- `ob_category_step.dart` — grid 2 colonnes, reuse `ContentCategory` enum existant, `togglePainPoint` style (multi-select)
- `ob_reminder_step.dart` — segmented teaser count + time picker horizontal

**Note** : step 6 actuel a déjà la logique quiz, on adapte dans les nouveaux widgets avec UX améliorée.

### Commit 8 — `feat(onboarding): permission primers (10-11)`

**Files** (NEW) :
- `ob_permission_photos_step.dart` — bullets + CTA `Permission.photos.request()` + "Plus tard"
- `ob_permission_notifs_step.dart` — bullets + preview notif mockup + CTA `localNotificationEngineInterfaceProvider.requestPermission()` + "Plus tard"

**Note** : réutilise le style `_OBPermissionStep` inline actuel, mais en widget dédié avec bullets + sub + skip.

### Commit 9 — `feat(onboarding): processing + demo + viral (12-14)`

**Files** (NEW) :
- `ob_processing_step.dart` — icon pulse + 1 message + mini progress bar, auto-advance 2s
- `ob_demo_step.dart` — Tinder swipe sur 5 PNG samples, validator `demoSwipedRightIndices.length >= 3`
- `demo_sample_card.dart` — card pour un sample (image + shadow)
- `ob_viral_moment_step.dart` :
  - `FutureBuilder` qui load `cards.json` → parse en `List<OnboardingSampleCard>` → prend les 3 associées aux indices swipés
  - Stack de 3 `_OnboardingPreviewCard` dans un `RepaintBoundary(key: _previewKey)`
  - CTA *Partager* :
    ```dart
    final RenderRepaintBoundary boundary = _previewKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/beedle-onboarding-preview.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path)], text: 'Mes 3 premières fiches Beedle 📓');
    ```
- `_OnboardingPreviewCard` — widget avec title/summary/action/intent eyebrow (pas `CardGlassTile`)

**Imports requis** :
```dart
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart'; // déjà présent
import 'package:share_plus/share_plus.dart';
```

**Test manual** :
- Swipe 3+ droite → CTA "Beedle digère ça pour toi" apparaît
- Processing → Viral → fiches affichées
- Share → native share sheet s'ouvre, PNG visible

### Commit 10 — `feat(onboarding): paywall with RevenueCat + analytics event`

**Files** :
- `ob_paywall_step.dart` — NEW (remplace `_OBPaywallStep` inline)
- `lib/features/onboarding/presentation/screens/onboarding.view_model.dart` — adapte `finishOnboarding()` pour logger PostHog

**Actions** :
1. Write `ob_paywall_step.dart` avec :
   - Logo BeedleIconAsset
   - Testimonial featured (même Antoine L. du Social Proof — extraire en const)
   - 2 plan cards (mensuel + annuel — annuel highlighted)
   - CTA primary : `_onStartTrial()` → `Purchases.getOfferings()` → `purchasePackage(selected)` → `finishOnboarding()` → `context.router.replace(const HomeRoute())`
   - CTA secondary : *Continuer en gratuit* → `finishOnboarding()` → `HomeRoute` (CÂBLÉ cette fois, plus d'onPressed vide)
   - CTA *Restaurer* → `Purchases.restorePurchases()` → check entitlements → Home si active
   - Error handling : try/catch `PlatformException` → `ScaffoldMessenger.showSnackBar`
2. Dans `onboarding.view_model.dart`, `finishOnboarding()` :
   - Persist `UserPreferencesEntity.onboardingCompletedAt` (déjà fait)
   - Append `analyticsService.track('onboarding_completed', { …payload })` avec les métadonnées listées au blueprint §4.14
3. Supprime `_OBPaywallStep` de `onboarding.screen.dart`

**Test manual** :
- Trial flow : sandbox iOS → popup Apple Pay → confirm → HomeRoute
- "Continuer en gratuit" : direct HomeRoute
- "Restaurer" : behavior correct si compte sandbox a déjà un achat
- PostHog dashboard (dev) : event `onboarding_completed` reçu avec payload

### Commit 11 — `feat(onboarding): accessibility labels + VoiceOver smoke test`

**Files modifiés** : tous les 12 widgets onboarding

**Actions** :
1. Wrap les tappables (GlassCards d'options, CTAs, swipe cards) dans `Semantics(label: ..., button: true, selected: ..., child: ...)`
2. Cards testimonials : `Semantics(label: '{name}, {persona} : {quote}')`
3. Tinder : `Semantics(label: '{statement}, swipe droite pour accepter')`
4. Smoke test VoiceOver iOS sur : Goal / Permission Photos / Paywall
5. Smoke test TalkBack Android sur les mêmes écrans

**Test manual** : VoiceOver activé iOS + navigation complète lisible.

---

## 6. Risks & Mitigations

| # | Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|---|
| R1 | **build_runner casse sur freezed v3 + riverpod v4** (vu dans la session précédente) | Moyen | Moyen | Patch manuel du freezed generated file si ça bloque (pattern déjà vu cette session sur `import.state.freezed.dart`). Documenter dans le commit. |
| R2 | **easy_localization regen peut overwriter les clés patchées manuellement** | Haut | Faible | Ne **pas** re-run `dart run easy_localization:generate` — patcher `locale_keys.g.dart` manuellement comme fait dans la session |
| R3 | **RevenueCat clés placeholder** → crash au `getOfferings()` sur un compte sandbox | Moyen | Moyen | Wrap dans try/catch, afficher un SnackBar d'erreur sans crasher l'onboarding. L'user peut quand même *Continuer en gratuit*. |
| R4 | **`share_plus` sur iOS demande une source rect** (iPad notamment) | Faible | Faible | Utiliser `shareXFiles(files, sharePositionOrigin: ...)` avec le Rect du bouton pour éviter crash iPad |
| R5 | **`RepaintBoundary.toImage()` rend un PNG vide si widget pas encore painted** | Moyen | Moyen | `await WidgetsBinding.instance.endOfFrame` avant le `toImage()`, ou utiliser `scheduleFrameCallback` |
| R6 | **PNG samples placeholder = visuel nul avant launch** | Certain | Faible | `// TODO-USER` explicites + éventuellement fournir un script `tool/capture_samples.sh` qui aide à créer les 5 PNG via screenshots ou Figma export |
| R7 | **Régression sur les fixes précédents** (permissions Podfile, Darwin init, UploadProgressCard, etc.) | Moyen | Haut | Checklist §4.9 du blueprint à revalider à chaque commit. Smoke test complet en fin de build. |
| R8 | **Onboarding trop long → drop-off avant paywall** | Moyen | Haut | À instrumenter post-launch avec PostHog funnel. Si drop-off > 50 % → retrancher écrans 05 (social proof) ou 07 (comparison) en priorité. |
| R9 | **Accessibility smoke test révèle des blockers** | Faible | Moyen | Pas bloquant pour ship — tracker les issues découverts dans un follow-up. |

## 7. Testing Strategy

### Unit tests (nice-to-have, pas bloquant pour MVP)
- `OnboardingStepValidator.canAdvance` sur tous les index + states
- `OnboardingSampleCard.fromJson` sérialisation/désérialisation
- `OnboardingViewModel.selectGoal` / `togglePainPoint` / `recordTinderSwipe`

### Integration smoke tests (manual)

| # | Scénario | Device | Pass criteria |
|---|---|---|---|
| 1 | Fresh install → full flow → paywall trial → Home | iOS sim + physical | Pas de crash, state persisté, event PostHog reçu |
| 2 | Fresh install → full flow → "Continuer en gratuit" → Home | Android | Home atteinte, prefs.hasCompletedOnboarding = true |
| 3 | "Plus tard" sur photos + notifs → flow continue | iOS physical | Permissions `denied` dans le state, onboarding termine OK |
| 4 | Back navigation | iOS | State preservé (goal conservé, painPoints conservés, tinder indices conservés) |
| 5 | Share viral moment | iOS physical | PNG généré, share sheet ouvre, file visible dans Photos après save |
| 6 | Share viral moment | Android | Pareil |
| 7 | VoiceOver Goal screen | iOS | Options lisibles, ordre logique, CTA Continuer annoncé |
| 8 | TalkBack Permission Photos | Android | Bullets + CTA lisibles |
| 9 | Dark mode full flow | iOS | Contrast OK sur tous les écrans |
| 10 | Reset data → re-onboarding | iOS | `SettingsScreen → Supprimer mes données → SplashRoute → OnboardingRoute` fonctionne |

## 8. Alternative approaches considered

| Option | Rejeté parce que |
|---|---|
| **Onboarding minimal (3-4 écrans)** | Brief explicite : user a choisi option (a) long pour max investissement psycho. Blueprint validé. |
| **Flutter `flutter_card_swiper` package** | Dépendance externe pour usage unique → `Dismissible` natif suffit |
| **Render live HomeScreen dans Welcome** | Complexe (stub state, providers override), fragile — PNG statique est stable |
| **Réutiliser `CardGlassTile` pour Viral Moment** | `CardEntity.embedding` non-nullable (1500 floats) — infaisable avec samples pré-bakés → widget dédié `_OnboardingPreviewCard` |
| **Persist goal/painPoints dans UserPreferencesEntity** | Pas de besoin métier prouvé pour le MVP → analytics seulement via PostHog. Évite schema migration ObjectBox. |
| **Onboarding linéaire (swipe horizontal PageView)** | User peut swiper accidentellement avant d'avoir choisi → `NeverScrollableScrollPhysics` + NavBar contrôlée (conservé du code actuel) |

## 9. Timeline estimate

Hypothèse : 1 dev solo (Clement), focus temps plein.

| Commit | Temps | Cumul |
|---|---|---|
| 1. Foundations | 1 h | 1 h |
| 2. Assets scaffold | 30 min | 1 h 30 |
| 3. Translations FR | 1 h 30 | 3 h |
| 4. Navigation scaffolding | 2 h | 5 h |
| 5. Hook + Self-discovery (4 widgets) | 3 h | 8 h |
| 6. Social + Bridge (3 widgets) | 2 h | 10 h |
| 7. Preferences (2 widgets) | 1 h 30 | 11 h 30 |
| 8. Permissions (2 widgets) | 1 h 30 | 13 h |
| 9. Processing + Demo + Viral (3 widgets + share_plus) | 4 h | 17 h |
| 10. Paywall + RevenueCat + analytics | 3 h | 20 h |
| 11. Accessibility | 1 h 30 | 21 h 30 |
| **Tests manuels + debug** | 3 h | **24 h 30 ≈ 3 jours** |

Buffer x1.5 → **5 jours full-time** réalistes incluant debug et itération.

## 10. Post-implementation

### Ce qui reste à faire hors plan (post-merge)

- [ ] Créer les **5 vrais PNG samples** + `home-preview.png` (script flutter screenshot ou mockup Figma)
- [ ] Remplacer les testimonials `TODO-USER` par de vrais (post-beta)
- [ ] Remplacer stats `TODO-USER` par des chiffres réels (post-beta)
- [ ] Finaliser le **pricing** : décider `{PRIX}` / `{PRIX_AN}` et les mettre à la place des placeholders
- [ ] Setup produits **RevenueCat dashboard** + clés sandbox + clés prod
- [ ] Traduction **EN** complète (remplacement des `TODO-TRANSLATE`)
- [ ] Skip handlers hors-onboarding : re-prompt photos à l'import + banner notifs sur Home (§4.11 blueprint)
- [ ] PostHog dashboard : créer le funnel `onboarding_started` → `onboarding_completed` pour analytics

### Mesures post-launch (instrumenter)

- Taux de complétion de l'onboarding (started / completed)
- Drop-off par écran (segmentation Amplitude/PostHog)
- Conversion paywall (% users qui cliquent *Commencer mon essai*)
- Conversion trial → paid (après 7 jours)
- Taux de partage viral (% users qui tap *Partager ces fiches*)

---

## 11. References

- [Blueprint source (refiné)](../onboarding-questionnaire-blueprint-2026-04-16.md)
- [Product brief Beedle](../product-brief-beedle-2026-04-15.md)
- [DESIGN.md CalmSurface](../DESIGN.md)
- [Skill source : adamlyttleapps/claude-skill-app-onboarding-questionnaire](https://github.com/adamlyttleapps/claude-skill-app-onboarding-questionnaire)
- Conventional commits spec : <https://www.conventionalcommits.org/>

---

## 12. Workspace setup

Avant de commencer à builder, **Wingspan vérifiera/créera une branche**
via `/create-branch`. Recommandation : `feat/onboarding-questionnaire-refactor`
pour isoler le refactor. Sur solo dev sans review PR, travailler direct
sur `main` reste acceptable — à choisir au lancement de `/vgv-wingspan:build`.

---

*Plan généré via `/vgv-wingspan:plan` — Claude Code · 2026-04-16*
*Prêt pour `/vgv-wingspan:build`*
