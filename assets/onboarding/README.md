# `assets/onboarding/`

Visual + data assets dédiés au flow onboarding-questionnaire (15 écrans).

## Status — TODO-USER avant launch

Tous les `.png` ci-dessous sont actuellement des **placeholders 1×1
transparents** (~67 bytes). Ils doivent être **remplacés** par les vrais
visuels avant le ship store. Cards.json contient déjà les 5 vrais titres
référencés par les samples PNGs (alignement title/PNG par nom de fichier).

| Fichier                                 | Spec                               | Status |
|-----------------------------------------|------------------------------------|--------|
| `mockup-home.png`                       | mockup iPhone Home (avec frame)    | **TODO-USER** |
| `mockup-card-detail.png`                | mockup iPhone Card Detail (avec frame) | **TODO-USER** |
| `demo-source-linkedin.png`              | faux screenshot LinkedIn (source de la démo simulée) | **TODO-USER** |
| `home-preview.png`                      | déprécié — remplacé par `mockup-home.png` | DEPRECATED |
| `samples/cards.json`                    | déjà rempli (preview cards Viral)  | OK ✅   |
| `samples/sample-*.png`                  | déprécié — Tinder-demo supprimé    | DEPRECATED |

## Comment générer les samples

Deux options :

1. **Capture in-vivo** : populate la Home avec 5 vraies fiches dont les
   titres correspondent aux entrées de `cards.json`, puis screenshot
   each card view en mode portrait.
2. **Mockup Figma** : reproduire le composant `_OnboardingPreviewCard`
   dans Figma (title, summary, actionLabel + intent badge), exporter
   chaque variante en PNG @3×.

Compresser via `pngquant --quality=70-85` ou `tinypng.com` avant de
commit (cible < 300 KB / fichier).
