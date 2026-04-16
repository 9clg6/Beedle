# App Icon Generation Pipeline — Beedle "Dot-b"

**Dernière mise à jour** : 2026-04-16
**Source de référence design** : [brainstorming-app-icon-2026-04-16.md](./brainstorming-app-icon-2026-04-16.md)

Ce document décrit comment générer et déployer les assets d'app icon Beedle
pour iOS, Android et web, à partir d'une seule source de vérité : le widget
Flutter [`BeedleIconAsset`](../lib/presentation/widgets/beedle_icon_asset.dart).

## Principe : un seul source of truth

Plutôt que d'éditer des PNG à la main dans Figma/Sketch, le design de l'icône
est encodé directement dans un widget Flutter. Toutes les variantes (light,
dark, monochrome) dérivent du même code et sont re-générables à volonté.

```
BeedleIconAsset widget  ──┐
  (Flutter + figma_squircle) │
                             ├──► tool/render_icon.dart
                             │      └──► PNG 1024×1024 masters
                             │              │
                             │              └──► flutter_launcher_icons
                             │                     ├──► ios/Runner/Assets.xcassets/
                             │                     ├──► android/app/src/main/res/mipmap-*/
                             │                     └──► web/icons/
                             │
                             └──► assets/branding/*.svg (reference mirrors)
```

Les SVG dans `assets/branding/` servent de **référence documentée** (ouvrables
dans un navigateur, commit-friendly pour les diffs visuels). Les PNG
production sont toujours générés depuis le widget Flutter — même pixels,
mêmes proportions, même anti-aliasing Hanken Grotesk.

## Pipeline complet

### 1. (Optionnel) Modifier le design

Si le design doit évoluer, éditer uniquement :

- **[lib/presentation/widgets/beedle_icon_asset.dart](../lib/presentation/widgets/beedle_icon_asset.dart)** pour la forme / couleurs / proportions
- **[assets/branding/icon-dot-b.svg](../assets/branding/icon-dot-b.svg)** et
  variantes pour garder les SVG de référence en phase (diff manuel,
  c'est juste pour la revue visuelle)

### 2. Générer les PNG masters

```bash
flutter test tool/render_icon.dart
```

Sortie (écrite dans `assets/branding/`) :

| Fichier                                         | Taille      | Usage                                    |
|-------------------------------------------------|-------------|------------------------------------------|
| `icon-source-1024.png`                          | 1024×1024   | iOS App Store, Google Play (master light)|
| `icon-dot-b-dark-1024.png`                      | 1024×1024   | iOS 18+ dark alternate image             |
| `icon-adaptive-foreground-1024.png`             | 1024×1024   | Android 8+ adaptive foreground layer     |
| `icon-notification-monochrome-1024.png`         | 1024×1024   | Android 13+ themed icon + status bar     |

**Note** : le script est un `testWidgets` parce que le Flutter binding a
besoin d'un offscreen canvas pour rasteriser les widgets — c'est le chemin
standard pour render-to-PNG en Flutter.

### 3. Générer les launcher icons

```bash
dart run flutter_launcher_icons
```

La configuration dans [pubspec.yaml](../pubspec.yaml) sous
`flutter_launcher_icons:` pointe vers les PNG masters générés à l'étape 2
et produit automatiquement :

**iOS** (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
- Icon-App-20×20@1x à @3x (notification, settings, spotlight)
- Icon-App-29×29@1x à @3x (settings)
- Icon-App-40×40@1x à @3x (spotlight)
- Icon-App-60×60@2x, @3x (app)
- Icon-App-76×76@1x, @2x (iPad)
- Icon-App-83.5×83.5@2x (iPad Pro)
- Icon-App-1024×1024@1x (App Store)
- Variantes Dark + Tinted (iOS 18+)

**Android** (`android/app/src/main/res/mipmap-*/`)
- mipmap-mdpi (48×48) jusqu'à mipmap-xxxhdpi (192×192)
- `ic_launcher.png` (classique)
- `ic_launcher_adaptive_fore.png` + `ic_launcher_adaptive_back.xml` (adaptive)
- Monochrome pour themed icons Android 13+

**Web** (`web/icons/`)
- favicon.png 16×16, 32×32
- Icon-192.png, Icon-512.png, Icon-maskable-192.png, Icon-maskable-512.png

### 4. Vérifier

**iOS** :
```bash
cd ios && pod install && cd ..
flutter run -d <iPhone>
```
Quitter l'app, vérifier l'icône sur le home screen. Basculer le système
en dark mode (Settings → Display & Brightness), l'icône doit swap vers
la variante sombre.

**Android** :
```bash
flutter run -d <Android>
```
Aller dans Settings → Wallpaper & Style → Themed icons (Android 13+) pour
tester la version monochrome tintée.

**Web** :
```bash
flutter build web
# Ouvrir build/web/index.html, check le favicon
```

## Workflow résumé (commit discipline)

Quand tu modifies le design :

```bash
# 1. Edit the widget + SVG reference
vim lib/presentation/widgets/beedle_icon_asset.dart
vim assets/branding/icon-dot-b.svg        # (+ les variantes si relevant)

# 2. Re-render the PNG masters
flutter test tool/render_icon.dart

# 3. Regenerate launcher icons
dart run flutter_launcher_icons

# 4. Check visually
flutter run

# 5. Commit everything in one atomic PR
git add lib/presentation/widgets/beedle_icon_asset.dart \
        assets/branding/ \
        ios/Runner/Assets.xcassets/AppIcon.appiconset/ \
        android/app/src/main/res/mipmap-*/ \
        web/icons/ \
        pubspec.yaml
git commit -m "feat(branding): update app icon design"
```

## Spécifications techniques (design tokens)

Pour référence future si tu veux régénérer depuis un autre outil :

| Token                        | Valeur                                              |
|------------------------------|-----------------------------------------------------|
| Canvas                       | 1024 × 1024 px                                      |
| Squircle corner radius       | 225 px (~22% du canvas)                             |
| Squircle corner smoothing    | 0.6 (iOS-style continuous curvature)                |
| Background gradient (light)  | `#FFFBF5` → `#FFE9D0` → `#FFDBB0` → `#FFC48A` vertical |
| Background (dark)            | solid `#0A0A0A`                                     |
| Letter glyph                 | lowercase `b`, Hanken Grotesk Bold (700)            |
| Letter italic                | skewX -8° (Matrix4.skewX(-0.14))                    |
| Letter color (light)         | `#0A0A0A` ink                                       |
| Letter color (dark)          | `#F0E3D0` warm cream                                |
| Letter font size             | 560 px (~55% du canvas)                             |
| Letter baseline              | y = 720 px (~70% du canvas)                         |
| Accent dot color             | `#FF6B2E` ember (signature, identique en dark)      |
| Accent dot diameter          | 72 px (~7% du canvas)                               |
| Accent dot position          | cx = 520, cy = 165                                  |
| Drop shadow (light only)     | offset (0, 24), blur 48, rgba(28, 28, 25, 0.08)     |

## Troubleshooting

**Le PNG généré n'a pas les bons pixels Hanken Grotesk**
GoogleFonts peut ne pas avoir chargé la police avant le render. Le script
appelle `pumpAndSettle()` pour attendre, mais si le network est lent,
relance. Alternative : précharger la font en amont via `GoogleFonts.pendingFonts`.

**L'icône iOS apparaît avec des coins légèrement sharp**
iOS applique son propre masque de squircle au-dessus de l'icône fournie.
C'est le comportement attendu — notre squircle `figma_squircle` est juste
là pour que la prévisualisation in-app (splash) et l'export correspondent.

**Le PNG monochrome a des artefacts de couleur**
`ColoredBox` avec un color ARGB 0x00 n'est pas toujours un fond totalement
transparent selon la plateforme de test. Si problème, ajouter `Clipper` ou
utiliser `Transparent` explicit via `Colors.transparent`.

## Liens

- Design source : [brainstorming-app-icon-2026-04-16.md](./brainstorming-app-icon-2026-04-16.md)
- Widget : [lib/presentation/widgets/beedle_icon_asset.dart](../lib/presentation/widgets/beedle_icon_asset.dart)
- Render script : [tool/render_icon.dart](../tool/render_icon.dart)
- SVG references : [assets/branding/](../assets/branding/)
- Design system : [DESIGN.md](./DESIGN.md)
