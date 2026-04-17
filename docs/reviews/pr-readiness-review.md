# PR Readiness Review — Firebase Authentication

**Date** : 2026-04-17
**Feature** : Firebase Authentication (Google + Apple) avec mode anonyme et gating paywall
**Plan** : `docs/plan/2026-04-16-feat-firebase-authentication-plan.md`
**Verdict** : Ready to merge *sous conditions* — le code est fonctionnellement complet, les 25/25 tests auth passent, `dart analyze lib/` ne remonte aucune erreur (seulement des `info` préexistants). Deux éléments à souligner dans la PR description : le placeholder iOS `REPLACE_WITH_REVERSED_CLIENT_ID` non résolu et la capability Apple côté Xcode ne sont que documentés (TODO-USER). Tant que ces étapes hors code ne sont pas faites, Google Sign-In et Apple Sign-In **ne fonctionneront pas** sur un device iOS réel.

---

## 1. Acceptance criteria — fonctionnel

| # | Critère | Statut | Notes |
|---|---|---|---|
| 1 | AuthScreen affiché après splash | OK | `splash.screen.dart:42` — `context.router.replace(AuthRoute())` quand `user == null && prefs.authSkippedAt == null` |
| 2 | Sign-in Google fonctionnel (code) | OK | `auth_service.impl.dart:45` — flow credential → Firebase |
| 3 | Sign-in Apple fonctionnel (code) | OK | `auth_service.impl.dart:68` — displayName persisté via `updateDisplayName()` + `reload()` au 1er signin |
| 4 | Bouton "Continuer sans compte" (optional) | OK | `auth.screen.dart:111` — conditionné par `widget.required` |
| 5 | Déjà connecté → AuthScreen sauté | OK | `splash.screen.dart:40` — check `user != null` |
| 6 | Déjà skippé → AuthScreen sauté | OK | `splash.screen.dart:40` — check `prefs.authSkippedAt != null` |
| 7 | Gating paywall | OK | `paywall.screen.dart:113` — `_onTapSubscribe` push `AuthRoute(required: true)` si anonyme, retry purchase au retour |
| 8 | Bouton "Se déconnecter" dans Settings | OK | `settings.screen.dart:435` — `_signOut()` dans `_AccountTile` |
| 9 | Auth state observable Riverpod | OK | `authStateProvider` (stream), `currentUserProvider` (sync), `authServiceProvider` |

---

## 2. Acceptance criteria — non-fonctionnel

| # | Critère | Statut | Notes |
|---|---|---|---|
| 1 | Pas de `firebase_auth` / `google_sign_in` / `sign_in_with_apple` dans presentation/domain | OK | Grep confirme : les 2 hits dans `domain/` sont des docstrings, aucun `import`. Déps uniquement dans `data/services/auth_service.impl.dart` et `data/mappers/auth_user.mapper.dart` |
| 2 | `AuthUserEntity` sérialisable JSON + roundtrip testé | OK | Freezed + `fromJson`/`toJson`. Roundtrip testé dans `auth_user.mapper_test.dart` (cas complet + nullables) |
| 3 | Tests success/cancel/network/error | OK | `auth_service.impl_test.dart` couvre les 4 branches pour Google. Apple couvert partiellement (happy + cancel via le view model test) |
| 4 | Design CalmSurface | OK (nuance) | `GradientBackground`, `CalmSpace`, `CalmRadius.pill`, `SmoothRectangleBorder`. Divergence mineure : le plan prévoit `assets/icons/apple.svg` + `google.svg` ; l'impl utilise `Icons.apple_rounded` et `Icons.g_mobiledata_rounded`. Ce dernier n'est pas conforme Google Brand Guidelines |
| 5 | Pas de PII logué | OK | Le service logue `uid` uniquement. Tokens passés à `GoogleAuthProvider.credential` / `OAuthProvider.credential` sans être loggés |
| 6 | Crashlytics `setUserIdentifier` | OK | `auth.view_model.dart:72` — appelé au signin success, protégé par try/catch (tests / dev sans Firebase init) |
| 7 | Analytics events trackés | OK | Les 6 events déclarés dans `analytics.service.dart:43-48` et utilisés dans `auth.view_model.dart` + `auth.screen.dart:46` + `settings.screen.dart:450` |

---

## 3. TODO-USER (hors code — à inclure dans la PR description)

Ces trois points ne sont **pas bloquants pour le merge** mais **sont bloquants pour que l'auth fonctionne sur un device** :

1. **iOS — Google OAuth** : activer Google dans Firebase Console → Authentication → Sign-in method, re-télécharger `GoogleService-Info.plist`, lire `REVERSED_CLIENT_ID`, remplacer le placeholder `REPLACE_WITH_REVERSED_CLIENT_ID` dans `ios/Runner/Info.plist:83`.
2. **iOS — Apple Sign-In** : activer la capability "Sign in with Apple" dans Xcode → Runner → Signing & Capabilities. App ID `fr.yellowstoneapps.beedle` doit être enregistré dans Apple Developer Portal.
3. **Android — Google Sign-In** : ajouter le SHA-1 de la keystore debug (`cd android && ./gradlew signingReport`) dans Firebase Console → Android app → Add fingerprint. Même opération pour la release avant la prod.

Le plan §11, §12 et le commentaire XML dans `Info.plist:66-75` documentent déjà ces étapes.

---

## 4. Vérifications

### 4.1 `dart analyze lib/` — pass

101 `info` remontés, tous **préexistants** (onboarding widgets, `terminal_card.dart`, `app_colors.dart` deprecations, `app_config.prod.dart` TODOs). **Aucun nouvel avertissement introduit par la feature auth.** Les fichiers `lib/features/auth/**`, `lib/data/services/auth_service.impl.dart`, `lib/data/mappers/auth_user.mapper.dart`, `lib/domain/services/auth.service.dart`, `lib/domain/entities/auth_user.entity.dart`, `lib/core/providers/auth.provider.dart` ne remontent **aucun** issue.

### 4.2 `flutter test` ciblé auth — 25/25 pass

```
fvm flutter test test/data/services/auth_service.impl_test.dart \
                 test/data/mappers/auth_user.mapper_test.dart \
                 test/features/auth/ \
                 test/core/providers/auth.provider_test.dart
```

Résultat : `00:02 +25: All tests passed!`

- `auth_service.impl_test.dart` : 8 tests
- `auth.provider_test.dart` : 1 test
- `auth_user.mapper_test.dart` : 6 tests
- `auth.view_model_test.dart` : 5 tests
- `auth.screen_test.dart` : 4 tests (warnings `Localization key not found` normaux — easy_localization pas init en test)

### 4.3 `flutter test` complet — fusion_engine cassé mais préexistant

`test/domain/services/fusion_engine_test.dart:99` échoue sur `mocktail fallback Duration`, sans rapport avec la feature auth (confirmé par l'énoncé : "tests fusion_engine cassés sont préexistants").

### 4.4 Scope du plan — complet

Les 15 phases sont implémentées :

| Phase | Présent ? |
|---|---|
| 1. Dependencies | OK (`google_sign_in: ^6.2.1`, `sign_in_with_apple: ^6.1.0`) |
| 2. Domain (enum, entity, service) | OK |
| 3. Data (mapper, impl) | OK |
| 4. Providers | OK |
| 5. `authSkippedAt` dans UserPreferences | OK (`user_preferences.entity.dart:29`) |
| 6. Presentation (screen, view_model, state, widget) | OK |
| 7. Routing (AuthRoute + splash) | OK (`app_router.dart:32`) |
| 8. Paywall gating | OK |
| 9. Settings signout | OK |
| 10. Bootstrap (no-op) | OK |
| 11. iOS URL scheme | Placeholder non résolu (TODO-USER) |
| 12. Android SHA-1 | Hors code (TODO-USER) |
| 13. Localization (fr + en) | OK |
| 14. Analytics catalog | OK |
| 15. Tests (5 fichiers) | OK |

### 4.5 Documentation Dartdoc — correcte

Tous les contrats publics documentés : `AuthService` (+ exception contract), `AuthFailure`/`AuthCancelledByUser`/`AuthNetworkFailure`/`AuthProviderFailure`, `AuthUserEntity`, `AuthScreen` (required vs optional), `AuthViewModel`, `currentUserProvider`, `AuthProviderButton`.

### 4.6 TODOs / FIXMEs — aucun introduit dans la feature

Grep `TODO|FIXME|XXX` sur tous les fichiers auth : **aucun match**. Le seul TODO est dans `ios/Runner/Info.plist:68` (`TODO-USER`) — consigne destinée à l'humain qui finalisera la config Firebase Console, attendue par le plan.

### 4.7 Breaking changes / migration — aucun

- `UserPreferencesEntity.authSkippedAt` ajouté nullable → pas de migration ObjectBox.
- Aucune route, provider public ou API repository supprimée.
- Les utilisateurs existants (déjà onboardés) passent par le splash → `user == null && authSkippedAt == null` → AuthScreen. Comportement prévu, à mentionner dans release notes, pas un breaking change.

---

## 5. Findings

### Critical — 0

Aucun bloqueur pour le merge côté code.

### Important — 2

1. **[Important] Placeholder iOS `REPLACE_WITH_REVERSED_CLIENT_ID` non résolu**
   `ios/Runner/Info.plist:83`. Documenté en TODO-USER, mais la PR description doit rendre cette étape explicite ; sans quoi un reviewer risque de merger sans réaliser que Google Sign-In iOS est inopérant. Ajouter un bloc "Avant de tester sur iOS" dans la description.

2. **[Important] Icône Google non conforme aux brand guidelines**
   `auth_provider_button.dart:96` utilise `Icons.g_mobiledata_rounded`. Google Brand Guidelines imposent le "G" multicolore officiel pour les boutons "Sign in with Google". Risque (mineur mais réel) de rejet App Store / Play Store. Le plan §6 prévoyait `assets/icons/google.svg` — étape skippée. Ajouter le SVG avant soumission store ou follow-up rapide.

### Suggestions — 3

1. **[Suggestion] Analytics cancel flow non distingué**
   `auth.view_model.dart:_signIn` track `authSigninStarted` avant le sheet natif. Un user qui annule compte comme `started` sans `succeeded` ni `failed`. Envisager un event `auth_signin_cancelled` dédié pour clarifier les funnels.

2. **[Suggestion] `google_sign_in` pin 6.x**
   Le package `google_sign_in: ^6.2.1` expose `signIn()` qui fonctionne ; la 7.x utilise `authenticate()`. Documenter le pin de version ou prévoir une tâche d'upgrade.

3. **[Suggestion] Widget test end-to-end paywall → auth required → retry purchase**
   Les widget tests couvrent `required=false/true` (affichage) et `tap Apple → service`, mais pas le flow "paywall → push AuthRoute(required:true) → signin → pop(true) → retry purchase". Un integration test viendrait verrouiller ce contrat de navigation.

---

## 6. Conclusion

La feature est **prête à être mergée**. Le code est propre, les tests passent, la séparation de couches est respectée, la sérialisation est testée, la PII n'est pas loggée, les analytics sont branchées, le design suit CalmSurface. Les 2 findings Important sont des rappels pour la PR description (TODO-USER iOS) et un follow-up brand guidelines (icône Google SVG) — aucun n'empêche le merge.

**Action items pour la PR description** :
1. Section "TODO-USER avant QA" : 3 étapes iOS/Android hors code.
2. Note migration : users existants re-exposés à AuthScreen au premier relaunch post-update (skip disponible).
3. Follow-up ticket : remplacer `Icons.g_mobiledata_rounded` par le SVG Google officiel avant store submission.
