# App Icon Generation Pipeline — Beedle "Dot-b"

**Dernière mise à jour** : 2026-04-16
**Source de référence design** : [brainstorming-app-icon-2026-04-16.md](./brainstorming-app-icon-2026-04-16.md)

Ce document décrit comment générer et déployer les assets d'app icon Beedle
pour iOS, Android et web, à partir d'une seule source de vérité : le widget
Flutter [`BeedleIconAsset`](../lib/presentation/widgets/beedle_icon_asset.dart).

## Principe : un seul source of truth

Plutôt que d'éditer des PNG à la main dans Figma/Sketch, le design de l'icône
est encodé directement dans des fichiers SVG commités (`assets/branding/`).
Toutes les variantes (light, dark, monochrome, adaptive foreground) dérivent
de ces sources et sont re-générables à volonté avec une seule commande.

Le widget Flutter [`BeedleIconAsset`](../lib/presentation/widgets/beedle_icon_asset.dart)
consomme le même design en rendu natif via `figma_squircle` pour l'affichage
in-app (splash, about). Les PNG production viennent, eux, des SVG.

```
assets/branding/*.svg  ──►  tool/render_icons.sh  ──►  PNG 1024×1024 masters
  (source of truth)         (rsvg-convert)                │
                                                          ├──► flutter_launcher_icons
                                                          │      ├──► ios/Runner/Assets.xcassets/
                                                          │      ├──► android/app/src/main/res/mipmap-*/
                                                          │      └──► web/icons/
                                                          │
                                                          └──► referenced by the
                                                               BeedleIconAsset widget
                                                               for in-app usage
                                                               (splash, etc.)
```

## Pourquoi un shell script + rsvg plutôt qu'un Flutter test ?

On avait d'abord tenté `flutter test tool/render_icon.dart` (rasteriser le widget via `RepaintBoundary.toImage()`). Cette approche s'est révélée non-viable : `google_fonts.hankenGrotesk()` bloque indéfiniment dans l'environnement `testWidgets` (attente réseau pour fetch la font → timeout 10 min). On est passé à `rsvg-convert` qui lit directement les SVG (~100ms pour les 4) et respecte exactement la source commitée.

Les SVG dans `assets/branding/` servent de **référence documentée** (ouvrables
dans un navigateur, commit-friendly pour les diffs visuels). Les PNG
production sont toujours générés depuis le widget Flutter — même pixels,
mêmes proportions, même anti-aliasing Hanken Grotesk.

## Pipeline complet

### Prérequis (one-time setup)

```bash
# SVG → PNG converter
brew install librsvg

# Install Hanken Grotesk so rsvg-convert matches the in-app rendering
mkdir -p ~/Library/Fonts
curl -sSL -o ~/Library/Fonts/HankenGrotesk-Bold.ttf \
  "https://github.com/google/fonts/raw/main/ofl/hankengrotesk/HankenGrotesk%5Bwght%5D.ttf"
curl -sSL -o ~/Library/Fonts/HankenGrotesk-BoldItalic.ttf \
  "https://github.com/google/fonts/raw/main/ofl/hankengrotesk/HankenGrotesk-Italic%5Bwght%5D.ttf"
fc-cache -f
```

### 1. (Optionnel) Modifier le design

Si le design doit évoluer, éditer les SVG dans `assets/branding/` :

- **[assets/branding/icon-dot-b.svg](../assets/branding/icon-dot-b.svg)** — master light (iOS + Android classique)
- **[assets/branding/icon-dot-b-dark.svg](../assets/branding/icon-dot-b-dark.svg)** — iOS 18+ dark variant
- **[assets/branding/icon-adaptive-foreground.svg](../assets/branding/icon-adaptive-foreground.svg)** — Android adaptive foreground (sans squircle, fond transparent)
- **[assets/branding/icon-notification-monochrome.svg](../assets/branding/icon-notification-monochrome.svg)** — status bar Android + tinted iOS 18

Éventuellement synchroniser le widget Flutter
[`BeedleIconAsset`](../lib/presentation/widgets/beedle_icon_asset.dart) si
les proportions/couleurs changent (pour que le splash reste cohérent).

### 2. Régénérer tous les assets en une commande

```bash
tool/render_icons.sh
```

Ce script fait deux choses :
1. Rasterise les 4 SVG en PNG 1024×1024 via `rsvg-convert`
2. Lance `dart run flutter_launcher_icons` qui dérive toutes les tailles
   iOS / Android / web depuis ces PNG

PNG intermédiaires produits (dans `assets/branding/`) :

| Fichier                                         | Taille      | Usage                                    |
|-------------------------------------------------|-------------|------------------------------------------|
| `icon-source-1024.png`                          | 1024×1024   | iOS App Store, Google Play (master light)|
| `icon-dot-b-dark-1024.png`                      | 1024×1024   | iOS 18+ dark alternate image             |
| `icon-adaptive-foreground-1024.png`             | 1024×1024   | Android 8+ adaptive foreground layer     |
| `icon-notification-monochrome-1024.png`         | 1024×1024   | Android 13+ themed icon + status bar     |

La configuration dans [pubspec.yaml](../pubspec.yaml) sous
`flutter_launcher_icons:` pointe vers les PNG masters générés à l'étape 2
(invoquée automatiquement par `tool/render_icons.sh`) et produit :

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
# 1. Edit the SVG source (+ the widget if proportions change)
vim assets/branding/icon-dot-b.svg        # (+ les variantes si relevant)
vim lib/presentation/widgets/beedle_icon_asset.dart

# 2. Re-render everything (SVG → PNG → launcher icons)
tool/render_icons.sh

# 3. Check visually — iOS needs a clean reinstall to refresh the cached icon
flutter clean && (cd ios && pod install) && flutter run

# 4. Commit everything in one atomic PR
git add lib/presentation/widgets/beedle_icon_asset.dart \
        assets/branding/ \
        ios/Runner/Assets.xcassets/AppIcon.appiconset/ \
        android/app/src/main/res/ \
        web/icons/ web/manifest.json web/favicon.png \
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

**Le PNG généré a une typo qui ne matche pas l'app (sans-serif générique au lieu de Hanken)**
Hanken Grotesk n'est pas installée en tant que font système — rsvg-convert
fallback sur une sans-serif. Refaire le one-time setup des prérequis pour
installer les TTF dans `~/Library/Fonts/`.

**L'icône iOS apparaît avec des coins légèrement sharp**
iOS applique son propre masque de squircle au-dessus de l'icône fournie.
C'est le comportement attendu — notre squircle dans le SVG est juste là
pour que la prévisualisation (in-app splash via `BeedleIconAsset`) et
l'App Store rendu correspondent visuellement.

**`flutter run` affiche encore l'ancienne icône**
iOS cache agressivement les icônes. Désinstalle manuellement l'app du
device, puis `flutter clean && cd ios && pod install && flutter run`.

**`dart run flutter_launcher_icons` échoue avec `PathNotFoundException`**
Les PNG masters n'ont pas été régénérés (ou `rsvg-convert` n'a pas rendu
les 4). Lance `tool/render_icons.sh` qui enchaîne les deux étapes.

## Liens

- Design source : [brainstorming-app-icon-2026-04-16.md](./brainstorming-app-icon-2026-04-16.md)
- SVG sources : [assets/branding/](../assets/branding/)
- Widget in-app : [lib/presentation/widgets/beedle_icon_asset.dart](../lib/presentation/widgets/beedle_icon_asset.dart)
- Render script : [tool/render_icons.sh](../tool/render_icons.sh)
- Design system : [DESIGN.md](./DESIGN.md)
