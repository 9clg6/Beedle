# VGV Review — feat: Firebase Authentication

**Date**: 2026-04-17
**Plan**: `docs/plan/2026-04-16-feat-firebase-authentication-plan.md`
**Scope revu**: ~21 fichiers (nouveaux + modifiés) + 5 fichiers de tests

---

## Synthèse

L'implémentation est dans l'ensemble solide et conforme à l'architecture cible : séparation des couches respectée, naming VGV correct (`FirebaseAuthService`, extension `dot.notation`, `.entity.dart`, `.view_model.dart`), sealed `AuthFailure` bien modélisé, mapper extension-based propre, et tous les tests passent (`25/25` après `fvm flutter test`).

Deux trous critiques cependant :

1. **Layer violation** — `auth.view_model.dart` importe directement `package:firebase_crashlytics/firebase_crashlytics.dart`, ce qui viole le critère non-fonctionnel explicite du plan (§3 : *"Aucune dépendance directe à `firebase_auth` / `google_sign_in` / `sign_in_with_apple` dans la couche presentation ni domain"*). Même si `firebase_crashlytics` n'est pas nommé explicitement, l'intention "aucune SDK Firebase dans presentation" est clairement posée (section 4.2). À abstraire derrière un `CrashReportingService`.
2. **Test coverage Apple manquant** — `signInWithApple` n'a **aucun test** dans `test/data/services/auth_service.impl_test.dart`. Le plan §15 liste explicitement 3 tests Apple attendus (happy/cancelled/displayName persistence). La section "Validation post-build" §8 exige "les 4 branches (success / cancel / network / provider failure) pour chaque méthode signin".

Quelques nits de style `very_good_analysis` (28 infos répartis entre `lib/` et `test/`) — aucun ne bloque mais plusieurs se corrigent en 30 secondes (tearoffs, `const`, redondance, underscores).

---

## Conformité aux critères VGV

| Critère | Statut | Commentaire |
|---|---|---|
| Naming `FirebaseAuthService` | OK | Pas `AuthServiceImpl`, conforme |
| Dot-notation fichiers (`.entity.dart`, `.view_model.dart`, `.mapper.dart`, `.service.dart`, `.enum.dart`, `.provider.dart`) | OK | Nomenclature respectée partout |
| `snake_case` fichiers | OK | OK |
| `abstract interface class` pour contracts | OK | `AuthService`, `AnalyticsService` |
| `sealed class` pour union types | OK | `AuthFailure` avec `final class` Cancelled/Network/Provider |
| `@freezed abstract class` | OK | `AuthUserEntity`, `AuthScreenState` |
| `@riverpod class` pour view model | OK | `AuthViewModel extends _$AuthViewModel` |
| Layer separation domain | OK | Seules deps : `freezed_annotation`, pas d'import SDK |
| Layer separation presentation | FAIL (CRITICAL) | `firebase_crashlytics` importé dans `auth.view_model.dart` |
| Types explicites sur variables locales | OK | `final User user`, `final AuthUserEntity user`, etc. (2 `final updated = ...` dans `settings.screen.dart` sont pré-existants, hors scope) |
| `final` privilégié | OK | Partout |
| `very_good_analysis` clean | PARTIAL | 5 infos sur `lib/` + 23 sur les tests. Aucun `error`, mais plusieurs infos faciles à clean |
| Riverpod conventions | OK | `Provider<T>`, `StreamProvider<T>`, `ref.watch` / `ref.read` selon usage ; pas d'effet de bord dans `build` du notifier |
| Pas d'effet de bord dans `build` (widget) | PARTIAL | `AuthScreen._AuthScreenState.initState` → `postFrameCallback` avec `analytics.track(...)` non-awaited. Linter signale (`discarded_futures` l.48). Acceptable avec un `unawaited(...)` explicite |
| mocktail (pas de classe mock manuelle) | OK | Tous les mocks étendent `Mock implements X` |
| Tests happy + cancel + network + provider failure (Google) | OK | 4 tests présents |
| Tests happy + cancel + network + provider failure (Apple) | FAIL (CRITICAL) | 0 test `signInWithApple` dans `auth_service.impl_test.dart`. Plan §15 + §8 l'exigent |
| Test `signOut` : appelle bien `_auth.signOut()` ET `_google.signOut()` | OK | Présent ligne 196-212 |
| Test `currentUser` null / mapped | OK | Présent |
| Test `authStateChanges` | OK | Présent |
| Test JSON roundtrip `AuthUserEntity` | OK | Présent (roundtrip + nullables) |
| Test `authProviderOf` fallback | OK | 4 cas : google / apple / vide / inconnu |
| Test view_model skip persiste `authSkippedAt` | OK | Présent avec `captureAny` |
| Widget test required=true vs required=false | OK | Présent |
| PII logging (tokens, refresh) | OK | Seul `uid` est logué (lignes 58, 93 de l'impl) |
| Crashlytics `setUserIdentifier(uid)` au signin | OK | L.72 view_model, wrapped en try/catch (best-effort) |
| Analytics events (6 auth events) | OK | Tous déclarés dans `AnalyticsEvent` + trackés |
| `AuthService` n'est jamais retourné comme impl | OK | Provider typed `Provider<AuthService>` |

---

## Findings

### [CRITICAL] 1. Violation de layer separation : `firebase_crashlytics` importé dans `presentation/`

**Fichier** : `lib/features/auth/presentation/screens/auth.view_model.dart:9`

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
```

Utilisation ligne 72 :

```dart
await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
```

Le plan §3 et §4.2 sont explicites : aucune dépendance SDK Firebase dans `presentation/`. Le critère général s'applique aussi à `firebase_crashlytics` (c'est un SDK Firebase).

**Fix suggéré** : abstraire derrière un contrat `CrashReportingService` dans `domain/services/`, avec une impl dans `data/services/` qui wrappe `FirebaseCrashlytics.instance`. Le view_model fait `ref.read(crashReportingServiceProvider).setUserIdentifier(user.uid)`. Cela permet aussi de mocker proprement en tests (actuellement le try/catch silence Crashlytics quand Firebase n'est pas init — un mock propre éliminerait ce couplage fragile).

---

### [CRITICAL] 2. Test coverage manquante : `signInWithApple`

**Fichier** : `test/data/services/auth_service.impl_test.dart`

Aucun `group('FirebaseAuthService.signInWithApple', ...)` présent. Le plan §15 liste :

- happy path → `AuthUserEntity` avec provider=apple
- cancelled (AuthorizationErrorCode.canceled) → `AuthCancelledByUser`
- persiste `displayName` si Apple ne le renvoie qu'à la 1ère connexion
- `FirebaseAuthException` → `AuthProviderFailure`

La section §8 renforce : *"couvre les 4 branches (success / cancel / network / provider failure) pour chaque méthode signin"*. Actuellement seul `signInWithGoogle` est couvert. La branche `user.updateDisplayName(...)` avec `apple.givenName != null && user.displayName == null` (impl lignes 86–91) n'est donc pas testée du tout.

**Impact** : régression silencieuse possible sur Apple (plateforme où le bug App Store rejection est le plus probable).

---

### [IMPORTANT] 3. `AuthScreenState` mélange un domain-type `AuthFailure` dans un state de presentation

**Fichier** : `lib/features/auth/presentation/screens/auth.state.dart:14`

```dart
const factory AuthScreenState({
  @Default(AuthScreenStatus.idle) AuthScreenStatus status,
  AuthFailure? error,
}) = _AuthScreenState;
```

Le state UI embarque directement le type `AuthFailure` (domain), ce qui est correct pour la couche mais empêche `AuthScreenState` d'être `fromJson/toJson`-sérialisable (et `AuthFailure` n'a pas de mapping JSON). Ce n'est pas utilisé ici donc c'est bénin, mais le `@Freezed(copyWith: true)` est redondant (c'est le défaut) et la factory `AuthScreenState.initial()` est tautologique avec `const AuthScreenState()`. Cosmétique.

---

### [IMPORTANT] 4. `AuthRoute()` et `OnboardingRoute()` pourraient être `const`

**Fichiers** :
- `lib/features/shared/presentation/screens/splash/splash.screen.dart:42` → `await context.router.replace(AuthRoute());`
- `lib/features/paywall/presentation/screens/paywall.screen.dart:116` → `await context.router.push(AuthRoute(required: true));`
- `lib/features/settings/presentation/screens/settings.screen.dart:401` → `context.router.push(AuthRoute(required: true))`

`AuthRoute` étant une route AutoRoute générée avec constructeur const, le ne-pas-const est une micro-régression perf + analyzer `prefer_const_constructors` (déjà détecté par le linter sur `auth_provider_button.dart:95` pour un cas similaire `_ButtonSpec`). À harmoniser.

---

### [IMPORTANT] 5. `AuthService` ne track pas l'event `authSignout` automatiquement

**Fichier** : `lib/data/services/auth_service.impl.dart:106-112`

Le `signOut()` fait `Future.wait([_auth.signOut(), _google.signOut()])` mais ne track pas `AnalyticsEvent.authSignout`. Actuellement l'event est tracké *côté widget* dans `settings.screen.dart:451`. Si demain un autre call-site fait `signOut()` (ex. purchase reset, account deletion), l'event sera muet. Le plan §3 acceptance criteria liste `auth_signout` sans préciser qui doit le push — mais la convention "source of truth unique" voudrait que l'impl s'en charge (cohérence avec les 3 autres events trackés ailleurs dans le view_model signin).

Alternative : garder le tracking côté widget mais documenter que tout appelant de `signOut()` *doit* tracker. Pas idéal.

---

### [IMPORTANT] 6. `authStateProvider.value` au lieu de `.valueOrNull` dans `currentUserProvider`

**Fichier** : `lib/core/providers/auth.provider.dart:26`

```dart
return ref.watch(authStateProvider).value;
```

Sur un `AsyncValue`, l'API moderne Riverpod recommande `.valueOrNull` qui est plus explicite sur l'intention (null si loading/error). `.value` throw si on lit en état `AsyncError` dans certaines versions. Le plan §4 recommandait `.valueOrNull`. Fonctionnel, mais à aligner.

---

### [IMPORTANT] 7. `Future`-returning analytics call dans `initState` non-await

**Fichier** : `lib/features/auth/presentation/screens/auth.screen.dart:44-50`

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref
      .read(analyticsServiceProvider)
      .track(AnalyticsEvent.authScreenViewed);
});
```

Le linter remonte `discarded_futures`. À wrapper `unawaited(...)` ou rendre le callback `async`. Fonctionnel mais bruit le `fvm dart analyze lib/`.

---

### [IMPORTANT] 8. `Info.plist` : placeholder `REPLACE_WITH_REVERSED_CLIENT_ID` commité

**Fichier** : `ios/Runner/Info.plist:83`

```xml
<string>com.googleusercontent.apps.REPLACE_WITH_REVERSED_CLIENT_ID</string>
```

C'est bien documenté en TODO-USER (plan Phase 11) et commenté dans le plist, mais laisser ce placeholder commité va casser le premier `fvm flutter build ios` en déclenchant un crash runtime `GIDClientID not found` au premier tap Google. Propositions : soit gitignore le placeholder + script `scripts/setup_google_signin.sh`, soit commiter une valeur qui ne crashera pas silencieusement (ex. `DO_NOT_USE`). Pas bloquant pour la review mais le plan §11 réclamait explicitement d'extraire depuis `GoogleService-Info.plist`.

---

### [SUGGESTION] 9. 23 infos linter sur les tests (tearoffs, const, underscores)

**Fichiers** : tous les tests auth

- `test/data/services/auth_service.impl_test.dart:36` → `_buildUser` local avec underscore leading interdit en Dart >=3.0 (`no_leading_underscores_for_local_identifiers`)
- Multiple `unnecessary_lambdas` dans `.thenAnswer((_) async => ...)` quand la closure est convertible en tearoff
- Plusieurs `avoid_redundant_argument_values` (ex : `_entity(provider: AuthProvider.google)` alors que c'est la valeur par défaut dans la factory)
- `avoid_escaping_inner_quotes` (utiliser `"` en outer)
- `unnecessary_underscores` (l.29 `(_, __) {}` -> `(_, _) {}` en Dart 3)
- Dans `auth.screen_test.dart` : 2 `unused_import` + 1 `unused_element` (`_StubRouter` déclaré mais jamais utilisé — peut être supprimé car on `pump` dans `MaterialApp.home`, pas dans un AutoRouter)

Aucun n'est un bug mais ça pollue le `dart analyze test/`.

---

### [SUGGESTION] 10. Doc-references cassées

**Fichiers** :
- `lib/features/auth/presentation/screens/auth.view_model.dart:14` → `[AuthScreen]` référencé en dartdoc mais pas importé
- `lib/features/auth/presentation/widgets/auth_provider_button.dart:18` → `[SquircleButton]` référencé mais le widget n'est pas dans scope

Cosmétique, linter `comment_references`. Ajouter les imports ou retirer les `[]`.

---

### [SUGGESTION] 11. Message d'erreur utilisateur pas branché

**Fichier** : `lib/features/auth/presentation/screens/auth.screen.dart:64`

Le snackbar affiche `next.error!.message` qui est un message *technique* en anglais (`"Firebase: invalid-credential"`, `"Platform: network_error"`). Les clés `auth.error_network` et `auth.error_provider` sont déclarées en fr/en mais jamais utilisées. Il faudrait mapper `AuthNetworkFailure` → `LocaleKeys.auth_error_network.tr()` et `AuthProviderFailure` → `LocaleKeys.auth_error_provider.tr()`. Sinon l'utilisateur français voit "Platform: network_error" ce qui est du bruit ingénieur.

---

### [SUGGESTION] 12. Loader indicator pas clickable-disabled de façon évidente

**Fichier** : `lib/features/auth/presentation/widgets/auth_provider_button.dart:51`

```dart
onTap: loading ? null : onPressed,
```

OK fonctionnellement, mais quand `onPressed` est `null` côté caller (parce que `state.status != idle`), le bouton ne devient pas visuellement disabled (pas d'opacity réduite, pas de feedback). Un `Opacity(opacity: onPressed == null ? 0.5 : 1.0)` ou équivalent serait plus lisible UX.

---

### [SUGGESTION] 13. Tests `authServiceProvider` Apple-flow non-simulés

**Fichier** : `test/data/services/auth_service.impl_test.dart`

Mocker `SignInWithApple` est plus subtil (classe statique `SignInWithApple.getAppleIDCredential`). Pour couvrir les 4 branches Apple il faudrait soit :
- injecter un `AppleSignInClient` abstrait dans `FirebaseAuthService` (refactor mineur, enabling)
- ou utiliser test zones pour mocker la static call (plus hacky)

Sans cela, la branche `updateDisplayName(...)` et la mise en cache post-1ère-connexion ne sont pas testées.

---

## Résultat de `fvm dart analyze` (lib/ + test/ scope auth)

- **Lib** : 5 infos (0 warnings, 0 errors)
- **Tests** : 3 warnings (unused_import x 2, unused_element x 1) + 20 infos (0 errors)

Total : 28 issues, dont 3 warnings.

## Résultat de `fvm flutter test`

- **25 tests** dans le scope auth (mapper + impl + view_model + screen + provider)
- **All tests passed** en ~2.5s

Observation : pendant le widget test, des warnings `[Easy Localization] [WARNING] Localization key [auth.title] not found` apparaissent car `EasyLocalization.load()` n'est pas initialisé dans le widget test. Les tests passent (parce que `.tr()` retourne la clé si non-trouvée), mais c'est un signal que la couverture UI n'atteint pas les vraies strings. Pas bloquant mais à considérer pour un golden test.

---

## Conclusion

L'implémentation fait ~90% de ce que le plan demandait, avec une architecture propre et testée. Les deux items critiques (`firebase_crashlytics` en presentation + zéro test Apple) sont des régressions par rapport aux acceptance criteria explicites — à corriger avant merge. Les 11 autres findings sont des polishes de qualité qui n'ont pas besoin de bloquer le PR mais gagnent à être batchés dans un commit de nettoyage.
