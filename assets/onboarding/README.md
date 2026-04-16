# `assets/onboarding/`

Visual + data assets dédiés au flow onboarding-questionnaire (15 écrans).

## Status — TODO-USER avant launch

Tous les `.png` ci-dessous sont actuellement des **placeholders 1×1
transparents** (~67 bytes). Ils doivent être **remplacés** par les vrais
visuels avant le ship store. Cards.json contient déjà les 5 vrais titres
référencés par les samples PNGs (alignement title/PNG par nom de fichier).

| Fichier                                 | Spec                               | Status |
|-----------------------------------------|------------------------------------|--------|
| `home-preview.png`                      | 9:16 · ~1080×1920 · < 300 KB · capture Home peuplée | TODO-USER |
| `samples/sample-prompt-eval.png`        | 9:16 · ~1080×1920 · < 300 KB · screenshot ou mockup | TODO-USER |
| `samples/sample-claude-code-skills.png` | idem                               | TODO-USER |
| `samples/sample-figma-autolayout.png`   | idem                               | TODO-USER |
| `samples/sample-dart-async.png`         | idem                               | TODO-USER |
| `samples/sample-raycast-cmd.png`        | idem                               | TODO-USER |
| `samples/cards.json`                    | déjà rempli avec 5 entrées         | OK ✅   |

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
