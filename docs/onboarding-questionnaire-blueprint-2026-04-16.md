# Onboarding Questionnaire — Blueprint & Handoff Beedle

**Date** : 2026-04-16
**Statut** : Blueprint validé par le porteur, **prêt pour implémentation**
**Handoff** : Wingspan (VGV) via `/vgv-wingspan:plan` → `/vgv-wingspan:build`
**Skill source** : [adamlyttleapps/claude-skill-app-onboarding-questionnaire](https://github.com/adamlyttleapps/claude-skill-app-onboarding-questionnaire)
**Contexte produit** : [product-brief-beedle-2026-04-15.md](./product-brief-beedle-2026-04-15.md) · [DESIGN.md](./DESIGN.md)

Ce document est **self-contained** : Wingspan peut l'utiliser comme brief complet
pour planifier et exécuter l'implémentation sans avoir à reconstruire la
session. Il couvre le **quoi**, le **pourquoi**, le **contenu exact de chaque
écran** et la **checklist d'implémentation** côté Flutter.

---

## 1. Contexte — pourquoi refondre l'onboarding

### Transformation story

**BEFORE** : l'utilisateur capture 5–10 screenshots tech/jour qu'il ne revoit
jamais. Sa pellicule est un cimetière. Il re-Google régulièrement des astuces
qu'il avait déjà capturées. Notion/Obsidian trop lourds à maintenir. Émotion
dominante : frustration silencieuse, sentiment de rater un levier évident.

**AFTER** : les screenshots deviennent des fiches digérées. L'app **pousse**
activement les bons contenus au bon moment (notif teaser). Recherche
sémantique par concept flou. Zéro tri, zéro tag. La veille devient une
vraie compétence appliquée.

### Benefit statements (5)

1. Tes screenshots digérés en fiches exploitables en <30 secondes
2. L'app te rappelle d'appliquer tes astuces au bon moment
3. Retrouve par concept flou, pas par date ou nom
4. Zéro dossier, zéro tag, zéro maintenance
5. Une bibliothèque vivante, pas un cimetière

### Décisions produit validées

- **Cible** : grand public tech-savvy via stores (FR/EN)
- **Trial** : 7 jours · pricing à décider → placeholders `{PRIX}` / `{PRIX_AN}` + `// TODO-USER`
- **Tonalité** : tech-explicit (gardons "veille IA", "prompt", "tuto")
- **Testimonials + stats** : tous inventés en placeholder marqués `// TODO-USER`
- **Viral moment** : (b) — export PNG de la fiche générée + native share sheet
- **Profondeur quiz** : (a) long — self-discovery 5–8 écrans, max investissement psychologique

---

## 2. Séquence — 15 écrans

```
HOOK (1)
├── 01. Welcome

SELF-DISCOVERY (3 — investissement psychologique)
├── 02. Goal question
├── 03. Pain points
├── 04. Tinder cards

SOCIAL (1)
├── 05. Social proof

BRIDGE (2 — "tu me comprends → voilà comment je fixe")
├── 06. Personalised solution
├── 07. Comparison table

PERSONALIZATION (2)
├── 08. Preferences — catégories
├── 09. Preferences — rappels

PERMISSIONS (2 — primées AVANT prompt natif)
├── 10. Permission photos
├── 11. Permission notifs

DEMO LOOP (3 — processing, demo, viral)
├── 12. Processing moment
├── 13. App demo (swipe 5 samples, pick 3)
├── 14. Value delivery + viral (export PNG + share)

CONVERSION (1)
└── 15. Paywall
```

---

## 3. Contenu détaillé par écran

Toutes les copies sont en **FR (default)**. Les clés EN suivront la même
structure dans `assets/translations/en.json` (traduction simple, même ton).

### 01 · Welcome

- **Headline (display.md, ink)** : *La veille qui se rappelle à toi.*
- **Sub (body.lg, neutral6)** : *Tes screenshots tech deviennent des fiches exploitables. Et l'app te rappelle d'y revenir quand tu en as besoin.*
- **Visual** : phone mockup squircle montrant la vraie `HomeScreen` Beedle avec `TerminalCard` ember + 2 `CardGlassTile`. Positionné 3/5 de la hauteur d'écran.
- **CTA primary (SquircleButton primary, full width)** : *Commencer*
- **Eyebrow doto ember au-dessus du CTA** : `[15 STEPS · 90 SEC]`

### 02 · Goal question (single-select)

- **Eyebrow (doto ember)** : `[QUESTION 1/3]`
- **Headline** : *Qu'est-ce que tu veux tirer de ta veille ?*
- **Sub** : *Une seule réponse — la principale pour toi.*
- **Options** (enum `OnboardingGoal`) :
  - 🛠️ **Construire plus vite** — ship avec les bonnes astuces → `buildFaster`
  - 🤖 **Tenir à jour avec l'IA** — ne rater aucun outil ou prompt → `stayAIUpToDate`
  - 📚 **Retenir les tutos** — que je capture tous les jours → `rememberTutorials`
  - 🎯 **Retrouver une info** — quand j'en ai besoin → `findInfoFast`
  - 🤝 **Partager** — avec mon équipe ou ma communauté → `shareWithTeam`
  - 🧭 **Explorer** — je découvre encore → `exploring`
- Sélection → border ember + check icon → CTA *Continuer* apparaît.

### 03 · Pain points (multi-select, min 1)

- **Eyebrow** : `[QUESTION 2/3]`
- **Headline** : *Qu'est-ce qui te bloque aujourd'hui ?*
- **Sub** : *Coche tout ce qui te parle.*
- **Options** (enum `PainPoint`) :
  - 🪦 Ma pellicule est un cimetière de screenshots → `pelliculeCemetery`
  - 🔎 Je re-Google des trucs que j'avais déjà sauvegardés → `reGoogle`
  - 🗂️ Notion / Obsidian me demandent trop de maintenance → `notionHeavy`
  - 📵 Je capture mais je n'y retourne jamais → `neverRevisit`
  - 🧠 J'oublie ce que je sais que je sais → `forgetWhatIKnow`
  - ⏰ Pas de rappel pour y revenir au bon moment → `noTimelyReminder`
  - 🤖 Les LLMs me font passer à côté d'astuces déjà vues → `llmMissOut`
- CTA *Continuer* grisé tant que 0 coché.

### 04 · Tinder cards (swipe 5)

- **Eyebrow** : `[JE ME RECONNAIS]`
- **Headline** : *Swipe droite si tu te reconnais.*
- **Sub** : *Aucune bonne réponse. Juste toi.*
- **5 cards empilées** (grande squircle, fond ink Aurora, texte display.sm blanc entre guillemets) :
  1. *« Je capture plein de trucs, mais je ne les revois jamais. »*
  2. *« J'ai déjà vu ce prompt quelque part… mais où ? »*
  3. *« Ma veille tech me coûte du temps, pas du levier. »*
  4. *« Les outils PKM me transforment en bibliothécaire. »*
  5. *« Je voudrais que l'app me pousse, pas l'inverse. »*
- Swipe droite ✓ ember / gauche ✗ neutral
- Progression en haut : `3/5`
- Auto-advance à la dernière.

### 05 · Social proof

- **Eyebrow** : `[BUILDERS COMME TOI]`
- **Stat big (display.md, ink)** : **87 %** des captures Beedle sont re-consultées dans le mois. `// TODO-USER: replace after beta data`
- **Sub** : *Rien ne meurt dans ta pellicule.*
- **3 testimonials** (GlassCard, vertical stack) — `// TODO-USER: remplacer par vrais testimonials post-beta` :
  - **Antoine L., 29 ans** · *iOS dev senior, Paris* — *"Je capture 10 tweets/jour. Beedle me renvoie exactement le bon tuto trois jours plus tard, au moment où j'en ai besoin."* ⭐⭐⭐⭐⭐
  - **Sarah M., 34 ans** · *PM, indie SaaS* — *"J'ai désinstallé Notion. Je ne perds plus mes prompts GPT dans la nature."* ⭐⭐⭐⭐⭐
  - **Nico R., 26 ans** · *Indie hacker* — *"847 screenshots dormants transformés en vrai workbook. J'aurais payé le double."* ⭐⭐⭐⭐⭐

### 06 · Personalised solution

- **Eyebrow** : `[VOILÀ COMMENT]`
- **Headline** : *On corrige ça — pour toi.*
- **Sub** : *Chaque bloqueur que tu as coché a son remède.*
- **4 paires** (pain neutral5 small, fix ink w600 + icône ember 24px) :
  - 🪦 *Pellicule cimetière* → **Chaque screenshot digéré en fiche exploitable, en <30 sec.**
  - 🔎 *Re-Google* → **Recherche sémantique — tape un concept flou, on sort la bonne fiche.**
  - 📵 *Jamais revu* → **Notifs teaser — 0 à 2/jour, calées sur tes habitudes.**
  - 🗂️ *Maintenance Notion* → **Zéro tag, zéro dossier, zéro tri. L'IA s'occupe de tout.**

### 07 · Comparison table

- **Stat big** : **94 %** de la veille tech reste inappliquée sans outil actif. `// TODO-USER: confirm stat source`
- **Sub** : *Voilà la différence.*
- **Table 2 colonnes** (header glass, rows alternées) :

  | | Sans Beedle | Avec Beedle |
  |---|---|---|
  | Digestion auto | ❌ | ✅ |
  | Rappels contextuels | ❌ | ✅ |
  | Recherche par concept | ❌ | ✅ |
  | Maintenance manuelle | 😩 Obligatoire | ✅ Zéro |
  | Veille appliquée | 6 % | **87 %** |

- **CTA primary** : *Je veux ça* (ember)

### 08 · Preferences — catégories

- **Eyebrow** : `[PERSONNALISATION 1/2]`
- **Headline** : *Qu'est-ce que tu captures le plus ?*
- **Sub** : *On règle tes rappels en fonction.*
- **Grid 2 colonnes**, multi-select, GlassCard par option :
  - 🤖 Tech / IA
  - 🎨 Design
  - 💼 Business
  - ⚡ Productivité
  - 🎬 Créatif
  - 🧪 Autre
- Reuse `ContentCategory` enum existant.

### 09 · Preferences — rappels

- **Eyebrow** : `[PERSONNALISATION 2/2]`
- **Headline** : *Tes rappels, ton rythme.*
- **Sub** : *Tu peux changer à tout moment dans les réglages.*
- **Section 1 — Rappels teaser** : segmented `0 / 1 / 2 / 3` par jour (default **1**) + légende *« On choisit le bon moment selon ton usage. »*
- **Section 2 — Rappel capture du soir** : time picker horizontal (intervalles 30 min, scrollable), default **20:00** + légende *« "Tu as des contenus à importer aujourd'hui ?" »*
- Reuse `teaserCountPerDay`, `captureReminderHour` existants.

### 10 · Permission photos

- **Eyebrow** : `[PERMISSION 1/2]`
- **Headline** : *Capture sans friction.*
- **Sub** : *Pour que l'import de screenshots soit un réflexe, pas une corvée.*
- **Bullets (icône ✓ ember, body.md)** :
  - Importe en 2 taps depuis ta pellicule
  - Share sheet depuis Twitter, Safari, Claude, n'importe où
  - **Tout reste sur ton téléphone — rien n'est uploadé**
- **CTA primary** : *Autoriser l'accès aux photos* → `Permission.photos.request()`
- **CTA ghost** : *Plus tard* → skip sans pénalité, advance.

### 11 · Permission notifs

- **Eyebrow** : `[PERMISSION 2/2]`
- **Headline** : *Ta veille, au bon moment.*
- **Sub** : *Sans ça, tu restes dans le cycle "je capture et j'oublie".*
- **Bullets** :
  - Maximum 2 rappels par jour (selon ton choix)
  - **Jamais de spam marketing — que du contenu de ta propre veille**
  - Tu peux désactiver à tout moment
- **Preview mockup notif** (iOS / Android adaptatif) :
  > *Beedle* · il y a 2 min
  > 💡 **Ce thread Claude Code que tu avais sauvegardé**
  > *3 astuces prêtes à appliquer sur ton workflow*
- **CTA primary** : *Activer les rappels* → `localNotificationEngineInterfaceProvider.requestPermission()`
- **CTA ghost** : *Plus tard*

### 12 · Processing moment

- Full-screen centered, background gradient Aurora warm
- `BeedleIconAsset(size: 128)` pulse via `AnimationController` (fade opacity 0.6→1.0 en boucle 1.2s)
- Texte body.lg ink qui change toutes les **800 ms** :
  1. *Calibrage du moteur IA...*
  2. *Configuration de tes préférences...*
  3. *Ta bibliothèque est prête.*
- Durée totale **~2.4 s** → auto-advance
- Sous le texte, mini progress bar horizontale animée (pseudo-loading)

### 13 · App demo (swipe 5, pick 3)

- **Eyebrow** : `[DÉMO · ESSAIE]`
- **Headline** : *Swipe droite sur ce que tu veux que Beedle digère.*
- **Sub** : *Minimum 3 captures.*
- **5 cards tinder** — chaque card = PNG pre-bakée dans `assets/onboarding/samples/` :

  | Index | Thème | Source simulée | Fichier asset |
  |---|---|---|---|
  | 0 | Prompt GPT pour éval LLM | tweet @simonwillison | `sample-prompt-eval.png` |
  | 1 | Thread Claude Code skills tips | thread X | `sample-claude-code-skills.png` |
  | 2 | Figma auto-layout shortcut | screenshot Figma | `sample-figma-autolayout.png` |
  | 3 | Snippet Dart async/await pattern | code GitHub | `sample-dart-async.png` |
  | 4 | Raycast command obscure mais utile | screenshot Raycast | `sample-raycast-cmd.png` |

- Progression en haut : `2 captures sélectionnées · min 3`
- Swipe ✓ droite (ember) / ✗ gauche (neutral)
- À **3+ swipes droite** : CTA primary apparaît → *Beedle digère ça pour toi* → advance.

### 14 · Value delivery + viral moment

- **Header animé 1.5 s** : *Digestion en cours...* + spinner ember (même visuel que le vrai pipeline — cohérence)
- **Reveal** : stack vertical des 3 fiches générées (pré-bakées dans `assets/onboarding/samples/cards.json`)
  - Chaque fiche = `CardGlassTile` custom avec :
    - Titre (headline.md)
    - Résumé 2 lignes (body.md)
    - Bouton action (ex: *Copier le prompt*, *Ouvrir le thread*, *Tester le snippet*)
    - Eyebrow intent (`[À TESTER]`, `[À LIRE]`, `[DOC]`)
- **Message au-dessus** : *Tu viens de créer ta première bibliothèque. Ne la perds pas.*
- **CTA primary** : *Continuer* → paywall
- **CTA secondary (icône share)** : *Partager ces fiches* →
  - Wrap la stack dans `RepaintBoundary(key: _previewKey)`
  - `_previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary`
  - `.toImage(pixelRatio: 3.0)` → `ByteData(PNG)` → fichier temp
  - `Share.shareXFiles([XFile(tempPath)], text: 'Mes 3 premières fiches Beedle 📓')`
  - Via package **`share_plus`** (à ajouter)

### 15 · Paywall

- **Logo** : `BeedleIconAsset(size: 72)` centered top
- **Headline display** : *Sors ta veille du cimetière.*
- **Sub body.lg** : *Rejoins les builders qui ne perdent plus un seul screenshot.*
- **Featured testimonial** (GlassCard, Antoine L. ⭐⭐⭐⭐⭐) — même personne que Groupe B, continuité
- **Plan card default** (GlassCard elevated, ember border 2px) :
  - Badge `MEILLEURE OFFRE` (digital ember)
  - *Annuel* · **`{PRIX_AN}` €/an** · ~**`{PRIX_AN_EFF}` €/mois** · *-45 %*
- **Plan card secondaire** (neutral border) :
  - *Mensuel* · **`{PRIX}` €/mois**
- **Placeholders** : `// TODO-USER: remplacer {PRIX} et {PRIX_AN} par le pricing final (brief mentionne 9€/59-69€)`
- **CTA primary (ember, full width)** : *Commencer mon essai gratuit — 7 jours*
- **Links secondary (ghost, inline)** : *Restaurer mes achats* · *Continuer en gratuit* · *CGU · Privacy*
- **Small print** : *7 jours gratuits. Annule à tout moment avant la fin du trial. Aucun débit automatique sans notification.*
- **Important** : le bouton *Continuer en gratuit* doit être **câblé** (`ref.read(onboardingViewModelProvider.notifier).finishOnboarding()` → `context.router.replace(const HomeRoute())`) — il était `onPressed: () {}` vide dans l'implémentation précédente.

---

## 4. Checklist d'implémentation (Phase 5 — Wingspan)

### 4.1. Dépendances à ajouter

```yaml
dependencies:
  share_plus: ^10.0.0  # Viral moment — native share sheet avec fichier PNG
```

### 4.2. Nouveaux enums (Dart)

Fichiers à créer sous `lib/domain/enum/` :

```dart
// onboarding_goal.enum.dart
enum OnboardingGoal {
  buildFaster,
  stayAIUpToDate,
  rememberTutorials,
  findInfoFast,
  shareWithTeam,
  exploring,
}

// pain_point.enum.dart
enum PainPoint {
  pelliculeCemetery,
  reGoogle,
  notionHeavy,
  neverRevisit,
  forgetWhatIKnow,
  noTimelyReminder,
  llmMissOut,
}
```

### 4.3. Extension de `OnboardingState`

Fichier : `lib/features/onboarding/presentation/screens/onboarding.state.dart`

Ajouter (sans casser l'existant) :

```dart
@Freezed(copyWith: true)
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentIndex,
    // Self-discovery (NOUVEAUX)
    OnboardingGoal? goal,
    @Default(<PainPoint>{}) Set<PainPoint> painPoints,
    @Default(<int>{}) Set<int> tinderAgreedIndices,
    // Demo (NOUVEAU)
    @Default(<int>{}) Set<int> demoSwipedRightIndices,
    // Preferences (existants)
    @Default(<ContentCategory>[]) List<ContentCategory> contentCategories,
    @Default(1) int teaserCountPerDay,
    @Default(20) int captureReminderHour,
    // Permissions (existants)
    @Default(false) bool notificationsGranted,
    @Default(false) bool photosGranted,
    // Submission (existant)
    @Default(false) bool isSubmitting,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState();
}
```

Régénérer le freezed : `dart run build_runner build --delete-conflicting-outputs`.

### 4.4. Extension du ViewModel

Fichier : `lib/features/onboarding/presentation/screens/onboarding.view_model.dart`

Ajouter méthodes (sans casser l'existant) :

```dart
void selectGoal(OnboardingGoal goal) =>
    state = state.copyWith(goal: goal);

void togglePainPoint(PainPoint p) {
  final Set<PainPoint> updated = {...state.painPoints};
  updated.contains(p) ? updated.remove(p) : updated.add(p);
  state = state.copyWith(painPoints: updated);
}

void recordTinderSwipe(int index, {required bool agreed}) {
  final Set<int> updated = {...state.tinderAgreedIndices};
  agreed ? updated.add(index) : updated.remove(index);
  state = state.copyWith(tinderAgreedIndices: updated);
}

void recordDemoSwipe(int index, {required bool picked}) {
  final Set<int> updated = {...state.demoSwipedRightIndices};
  picked ? updated.add(index) : updated.remove(index);
  state = state.copyWith(demoSwipedRightIndices: updated);
}
```

Adapter `next()` / `previous()` / `goTo()` : maintenant **15 écrans** (index 0-14) au lieu de 11.

### 4.5. Nouveaux widgets Flutter

Fichiers à créer sous `lib/features/onboarding/presentation/widgets/` :

- `ob_welcome_step.dart`
- `ob_goal_step.dart`
- `ob_pain_points_step.dart`
- `ob_tinder_step.dart` (+ `ob_swipe_card.dart` pour les cards individuelles)
- `ob_social_proof_step.dart`
- `ob_solution_step.dart`
- `ob_comparison_step.dart`
- `ob_category_step.dart`
- `ob_reminder_step.dart`
- `ob_processing_step.dart`
- `ob_demo_step.dart` (+ `demo_sample_card.dart`)
- `ob_viral_moment_step.dart` (inclut export PNG + share)

**Refonte** : `_OBPaywallStep` existant → consolidé à 1 seul écran (absorbe l'ancien step10 "Choisis ton plan") avec la structure du §15 ci-dessus.

### 4.6. Assets pré-bakés

Structure à créer :

```
assets/onboarding/samples/
├── sample-prompt-eval.png              # screenshot tweet @simonwillison éval LLM
├── sample-claude-code-skills.png       # thread X skills Claude Code
├── sample-figma-autolayout.png         # screenshot Figma auto-layout
├── sample-dart-async.png               # snippet Dart async/await
├── sample-raycast-cmd.png              # screenshot Raycast
└── cards.json                          # 3 fiches générées pré-bakées
```

`cards.json` contient les 3 cards générées qui s'afficheront dans le viral moment — titre, résumé, action, intent, tags. Schema à aligner sur `CardEntity` pour pouvoir réutiliser `CardGlassTile`.

`// TODO-USER: créer les 5 PNG screenshots samples — peut être fait en capturant de vrais contenus publics ou en générant des mockups via Stitch / Figma.`

Déclarer dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/translations/
    - assets/branding/
    - assets/onboarding/samples/  # NEW
```

### 4.7. Traductions

Ajouter ~70 nouvelles clés dans `assets/translations/fr.json` et `en.json` sous la branche `onboarding.*`. Convention :

- `onboarding.welcome.{title,subtitle,cta,eyebrow}`
- `onboarding.goal.{title,subtitle,eyebrow,option_xxx}` × 6 options
- `onboarding.pain.{title,subtitle,eyebrow,option_xxx}` × 7 options
- `onboarding.tinder.{title,subtitle,eyebrow,card_1..card_5}`
- `onboarding.social.{title,stat_big,stat_todo,testimonial_1..3}`
- `onboarding.solution.{title,subtitle,eyebrow,item_1..4_pain,item_1..4_fix}`
- `onboarding.comparison.{stat_big,subtitle,row_xxx}` × 5 rows
- `onboarding.category.{title,subtitle,eyebrow}` (options déjà traduites dans step6 existant)
- `onboarding.reminder.{title,subtitle,eyebrow,teaser_legend,reminder_legend}`
- `onboarding.perm_photos.{title,subtitle,bullet_1..3,cta,skip}`
- `onboarding.perm_notifs.{title,subtitle,bullet_1..3,cta,skip,preview_title,preview_body}`
- `onboarding.processing.{msg_1,msg_2,msg_3}`
- `onboarding.demo.{title,subtitle,eyebrow,progress,cta}`
- `onboarding.viral.{processing,intro,cta_primary,cta_share}`
- `onboarding.paywall.{title,subtitle,badge,plan_yearly,plan_monthly,cta_trial,cta_free,cta_restore,small_print}`

Régénérer ensuite `lib/generated/locale_keys.g.dart` via `dart run easy_localization:generate` (ou patch manuel comme on a fait précédemment).

### 4.8. Refonte du screen

Fichier : `lib/features/onboarding/presentation/screens/onboarding.screen.dart`

- Passer le `PageView` de 12 à **15 pages** (`children: List.generate(15, ...)`)
- Remplacer les imports des vieux hero `_OBHero` par les nouveaux widgets
- Ajuster `total: 15` dans `CalmSegmentedProgress`
- Dans `_NavBar`, ajuster : `i < 14` au lieu de `i < 11` pour le bouton Next
- `canSkip` : `i >= 5 && i < 12` (entre le tinder et les permissions)

### 4.9. Intégration avec les fixes déjà faits (préservés)

- ✅ Permissions iOS Podfile (`PERMISSION_PHOTOS=1`, `PERMISSION_NOTIFICATIONS=1`)
- ✅ `DarwinInitializationSettings(requestAlertPermission: false, ...)` dans `local_notification_engine.impl.dart`
- ✅ `requestPhotos()` wire correcte (déjà fait)
- ✅ Bouton "Continuer en gratuit" du paywall — à câbler cette fois sur `finishOnboarding()` + pop vers Home
- ✅ `UploadProgressCard` sans `BackdropFilter` (pas directement impacté mais à ne pas régresser)

### 4.10. Test plan

- Fresh install iOS → onboarding complet → paywall trial → Home vide (pas de cards)
- Fresh install Android → idem
- Tap "Plus tard" sur photos + notifs → flow continue, onboarding termine OK
- Tap "Continuer en gratuit" sur paywall → user atteint Home sans abonnement, `hasCompletedOnboarding: true`
- Bouton back via `_NavBar.previous()` → state conservé (si back sur goal, la sélection reste)
- Share sur écran 14 → PNG généré + native share sheet s'ouvre
- Dark mode : tester chaque écran (mono-variante `BeedleIconAsset` déjà prête)
- Run `flutter analyze` après chaque étape → 0 errors / warnings
- Run `dart format` avant commit

---

## 5. Définition of Done

- [ ] 15 écrans implémentés dans `lib/features/onboarding/presentation/widgets/`
- [ ] `OnboardingState` étendu + ViewModel étendu, `build_runner` ok
- [ ] `share_plus` ajouté, export PNG fonctionne sur iOS + Android
- [ ] 5 PNG samples + `cards.json` dans `assets/onboarding/samples/`
- [ ] ~70 clés de traduction FR + EN, `locale_keys.g.dart` régénéré
- [ ] Tous les `// TODO-USER` marqués pour remplacement post-beta (testimonials, stats, pricing)
- [ ] `flutter analyze` : 0 error, warnings pré-session tolérés
- [ ] `dart format` : 100% formatté
- [ ] Test manuel iOS + Android : full flow sans crash
- [ ] Preview PNG generation : file opens dans Photos/Files après share
- [ ] Bouton "Continuer en gratuit" câblé + testé

---

## 6. Ce qu'on préserve (ne pas régresser)

- `CalmSegmentedProgress` (progress bar) · `SquircleButton` · `GlassCard` · design tokens CalmSurface
- `permission_handler` + `flutter_local_notifications` setup (fixes déjà appliqués)
- `finishOnboarding()` dans le ViewModel (persist `UserPreferencesEntity`)
- `_OBPaywallStep` structure (à refresher, pas à jeter)
- Fixes OS permissions (Podfile macros, Darwin init)
- App icon Dot-b + splash natifs
- `UploadProgressCard` sans BackdropFilter (pas directement impacté)

---

## 7. Handoff Wingspan

Workflow suggéré côté Wingspan :

1. `/vgv-wingspan:refine-approach` — lire ce doc + [DESIGN.md](./DESIGN.md), valider que rien ne manque
2. `/vgv-wingspan:plan` — produire le plan d'implémentation détaillé (ordre des commits, risques)
3. `/vgv-wingspan:build` — exécuter le plan écran par écran
4. `/vgv-wingspan:review` — vérifier avant merge
5. `/vgv-wingspan:create-commit` — commit conventional message par batch logique

Ce blueprint (fichier actuel) **est** le brainstorm source pour Wingspan. Pas besoin de refaire les phases 1-4.

---

*Généré par `/app-onboarding-questionnaire` — Claude Code · 2026-04-16*
