# Brainstorming Session — App Icon Beedle

**Date** : 2026-04-16
**Objectif** : Définir 3 à 5 concepts d'app icon aboutis pour Beedle (iOS + Android).
**Phase projet** : MVP v0.1.0 (BMAD Method v6, Level 2)
**Animation** : Creative Intelligence (BMAD)

---

## Cadrage

### Positionnement
- **Nom** : Beedle (référence *The Tales of Beedle the Bard* — territoire conteur / recueil / barde)
- **Tagline** : *« La veille qui se rappelle à toi »* / *"The watchlist that pings you back"*
- **Core loop** : capture screenshot → OCR + LLM digestion → card consultable → rappel intelligent

### Contraintes design
- **Style** : abstrait-géométrique (école Nothing · Base44 · Arc · Raycast)
- **Design system** : CalmSurface v0.1 (voir `docs/DESIGN.md`)
- **Palette autorisée** : ember `#FF6B2E` · mint `#DEEFA0` · canvas `#FBF8F3` · ink `#0A0A0A` · Aurora warm gradient
- **Forme** : squircle avec `cornerSmoothing ≥ 0.6`
- **Sensations** : *warm, calm, a bit playful, crafted*
- **Livrable** : 3-5 concepts aboutis prêts à raffiner avec un designer

### Exclusions strictes (anti-clichés)
- ❌ Sparkle / étoile / glow — cliché IA
- ❌ Cerveau / node network — cliché IA
- ❌ Appareil photo / polaroid — trop littéral
- ❌ Engrenage / circuit — anti-calm
- ❌ Abeille réaliste — mascotte infantilisante
- ❌ Livre 3D pages détaillées — skeuomorphisme
- ❌ Gradient bleu/violet — hors brand
- ❌ Typo serif précieuse — contredit "playful"

---

## Techniques appliquées

1. **Mind Mapping** — cartographie des territoires symboliques dérivés du nom et du core loop
2. **SCAMPER** — mutation systématique de la lettre `b` (glyphe pivot)
3. **Reverse Brainstorm** — validation par négation des pièges à éviter

---

## Ideas Generated

### Territoires symboliques (Mind Map) — 6 branches

| # | Territoire | Sous-pistes |
|---|---|---|
| A | **Seal** (sceau) | monogramme, cachet de cire, estampille, glyph, rune, moniker, écusson |
| B | **Book** (tome) | spine/tranche, bookmark/signet, page tournée, scroll, pile de livres, fold/pli |
| C | **Writing** (écriture) | caret clignotant, underscore `_`, plume, point-virgule, typographique, ink drop |
| D | **Memory** (rappel) | hook, signet, pli/corner, loop/cycle, accroche, ring, revisit |
| E | **Typo `b`** | lowercase bold italique, uppercase `B`, ligature `be`/`bd`, `b·`, `b_`, `]b[`, bowl ouvert |
| F | **Axes transversaux** | Hanken Grotesk vs custom Art Deco · ember fond vs Aurora fond · glyphe canvas vs ink · point ember composable |

### Transformations SCAMPER — 22 variations concrètes

**Substitute**
1. Barre verticale du `b` → caret ember plein
2. Bowl du `b` → bracket `]`
3. Bowl fermé → bowl ouvert bas-droit

**Combine**
4. `b` + point ember → `b·`
5. `b` + underscore → `b_`
6. `b` + encoche → `[b` ou `b]`

**Adapt**
7. `b` estampé relief matelassé (sceau de cire)
8. Bowl replié en triangle (page cornée)
9. `b` reconstruit en 3 traits droits + 1 arc (rune)

**Modify**
10. Proportions Art Deco (ascender ultra long)
11. Italicisation 8-12°
12. Contre-forme évidée (négatif porteur)

**Put-to-other-uses**
13. Glyphe = avatar/favicon
14. Point seul = notification badge
15. Glyphe = watermark card

**Eliminate**
16. Retirer la barre → goutte/grain pure
17. Retirer le bowl → caret seul
18. Retirer couleur → silhouette ink/canvas

**Reverse**
19. `b` inversé → ligature `bd`
20. Fond coloré vs fond neutre
21. Lowercase → uppercase italique

### Anti-patterns (Reverse Brainstorm) — 12 à éviter
sparkle · brain-nodes · camera · gear/circuit · realistic bee · 3D book · blue/purple gradient · fancy serif · glow effect · illustrated character · refresh arrow · uppercase initial fullbleed

---

## 5 Concepts finalistes

### Concept 1 — The Caret
*Curseur d'écriture ember, rectangle vertical pur (ratio 1:3), position légèrement décentrée sur squircle canvas.*

- **Rationale** : signature unique au store. Lien direct au TerminalCard du DNA visuel. Incarne « ta veille va se raconter ».
- **Palette** : canvas · caret ember · dark mode = ink/ember
- **Variations** : caret seul · caret + point sous · splash animé blink
- **Force** : distinctivité maximale
- **Faiblesse** : pas de lien nominal

### Concept 2 — The Dot-b ⭐ *(meilleur équilibre)*
*`b` minuscule Hanken Grotesk Bold italique 8° ink, surmonté d'un point ember au-dessus de l'ascender. Fond Aurora warm.*

- **Rationale** : lien nominal direct (lettre `b`). Point ember = tagline *ping back*. Asymétrie ownable. Point réutilisable comme badge.
- **Palette** : Aurora warm vertical · `b` ink · point ember
- **Variations** : point haut/droit/intégré · dark = ink fond, b canvas
- **Force** : équilibre identité / lisibilité / ownership

### Concept 3 — The Fold
*`b` minuscule dont le bowl est un triangle replié révélant ember dessous. Métaphore page cornée.*

- **Rationale** : le seul concept narratif — *on corne la page pour y revenir*. Encode la promesse du produit.
- **Palette** : canvas · barre+contour ink · intérieur pli ember
- **Variations** : angle 30°/45°/60° · révélation mint au lieu d'ember
- **Force** : storytelling
- **Faiblesse** : exécution fine exigée

### Concept 4 — The Seal
*`b` lourd (Black/ExtraBold) en canvas sur fond ember flat, `cornerSmoothing 0.75`. Effet cachet de cire moderne.*

- **Rationale** : monogramme éditorial, tradition du barde qui appose sa marque. Ultra lisible, safe, institutionnel.
- **Palette** : ember · canvas (inversable)
- **Variations** : poids du `b` · ratio 45/55/65% · embossage 1px subtil
- **Force** : safe + lisibilité universelle
- **Faiblesse** : moins surprenant

### Concept 5 — The Stroke-b
*`b` reconstruit en 3 traits géométriques minimaux : barre + courbe + point terminal ember. Inspiration runique.*

- **Rationale** : architectural, modulaire, signature-first. Les 3 pièces composables → système visuel complet.
- **Palette** : traits ink · point ember · fond canvas ou Aurora
- **Variations** : épaisseur strokes · position du point · organique vs quasi-rectangulaire
- **Force** : déclinabilité système

---

## Matrice comparative

| Concept | Identité nom | Distinctivité | Craft | Lisibilité 16px | Déclinabilité | Cohérence DESIGN.md |
|---|---|---|---|---|---|---|
| 1. Caret | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 2. Dot-b | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 3. Fold | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| 4. Seal | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 5. Stroke-b | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## Insights clés

### Insight 1 — Le `b` minuscule est la bonne porte
**Source** : Mind Map + SCAMPER convergent (4/5 concepts)
**Impact** : Haut · **Effort** : Faible
Italique 8°, grotesque warm, casual lowercase = exactement "warm/calm/playful/crafted".

### Insight 2 — Le point ember ≠ un sparkle
**Source** : SCAMPER Combine + Reverse Brainstorm
**Impact** : Haut · **Effort** : Faible
Contourne le cliché IA tout en offrant signal de vivacité et composable comme notification badge.

### Insight 3 — Le caret est notre arme identitaire
**Source** : Convergence 3 techniques
**Impact** : Haut · **Effort** : Moyen
TerminalCard déjà dans le DNA code (`terminal_card.dart`). Décision radicale mais cohérente.

### Insight 4 — Le fold est le seul à raconter
**Source** : Mind Map territoire Book
**Impact** : Moyen · **Effort** : Haut
Seul concept narratif (on corne = on revient). Exécution exigeante.

### Insight 5 — Tous sont déclinables en système
**Source** : SCAMPER Put-to-other-uses
**Impact** : Haut · **Effort** : Faible
Chaque glyphe peut devenir watermark cards, avatar, favicon, notification badge. Penser *identité* pas seulement *icône*.

---

## Statistiques

- **22** transformations concrètes générées (SCAMPER)
- **6** territoires symboliques cartographiés (Mind Map)
- **12** anti-patterns identifiés (Reverse Brainstorm)
- **5** concepts finalistes livrés
- **6** critères de validation établis
- **Total** : 45+ idées brutes distillées en 5 directions aboutues

---

## Recommandation stratégique

**Finalistes à poursuivre** : prioriser **Concept 2 (Dot-b)** et **Concept 1 (Caret)** — les deux extrêmes du spectre identité/distinctivité.

- **Si tu veux l'option safe + reconnaissable qui porte le nom** → Dot-b
- **Si tu veux l'option signature forte qui deviendra la marque distinctive** → Caret
- **Idée radicale** : utiliser les *deux* en système — Caret sur l'icône marketing/splash (signature émotive), Dot-b comme watermark des cards et avatar (lien nominal).

## Prochaines étapes recommandées

1. **Mockups visuels** (Figma ou Stitch MCP) des 5 concepts en icônes 1024×1024 + preview 16/32/60/180px pour valider la lisibilité petite taille.
2. **Tests A/B éclair** sur 3 personnes cibles : laquelle mémorise-t-on après 2 secondes ?
3. **Variations déclinaison** : notification badge, avatar, favicon, dark mode de chaque finaliste retenu.
4. **Brief designer** : si sous-traitance, fournir ce document + 3 refs Nothing/Base44/Arc similaires pour calibrer.
5. **Optionnel** — Générer les mockups via Stitch MCP : je peux lancer `/stitch-design` avec le brief du concept choisi si tu veux voir immédiatement une preview.

---

*Généré par BMAD Method v6 — Creative Intelligence*
*Durée session : ~30 minutes · Techniques : Mind Mapping + SCAMPER + Reverse Brainstorm*
