# ADR-005 — Content model pivot (fullContent as core) + Gamification Tier 2

**Date :** 2026-04-15
**Status :** Accepted (pivot en cours de session)
**Context :** Lors de la 2ᵉ session de brainstorm, le porteur a clarifié que le modèle initial de `Card` (summary + steps + codeBlocks structurés) était faux. La vraie intention : la fiche est **le contenu verbatim nettoyé**, avec un résumé **au-dessus** comme header. Le hook de notification se calcule depuis le contenu complet. Parallèlement, le porteur a demandé l'ajout de **gamification Tier 2** (streak + activity graph + XP/niveaux + 10+ badges + défis hebdo).

## Decision

### Content model

- `CardEntity` reçoit un nouveau champ `fullContent` (String markdown, cœur de la fiche).
- Suppression de `steps` (`List<String>`) et `codeBlocks` (`List<String>`) — ils deviennent **inline dans le markdown** (listes numérotées + ```fenced code```).
- Le `summary` reste mais devient un **TL;DR court (2-3 phrases)** affiché dans un glass card en header. Il n'est plus le cœur.
- `teaserHook` est généré par le LLM **à partir de `fullContent`**, pas du summary.
- Prompt LLM mis à jour : rôle = **nettoyage + formatage** (pas résumer).
- JSON schema OpenAI simplifié (6 champs au lieu de 8).
- Embedding calculé sur `title + tags + fullContent` pour recherche sémantique plus riche.
- UI Card Detail refondue : meta chips + titre + glass card summary + tags + `flutter_markdown` rendering de `fullContent` + actions. Les blocs code ```...``` sont rendus via un `MarkdownElementBuilder` custom avec bouton Copier contextuel.

### Gamification Tier 2

- Ajout de **4 entités** : `GamificationStateEntity` (agrégat XP/streak/badges singleton), `ActivityDayEntity` (log jour par jour), `WeeklyChallengeEntity` (défi hebdo).
- Ajout de **4 enums** : `BadgeType` (16 badges avec icônes emoji), `BeedleLevel` (5 niveaux par thresholds XP), `XpEvent` (import=5, view=10, test=50, streakBonus=30, challenge=100), `ChallengeType`.
- Ajout d'un `GamificationEngine` service, hooké dans `ImportScreenshotsUseCase`, `MarkCardViewedUseCase`, `MarkCardTestedUseCase`.
- 3 nouveaux local models + data source + repository impl + mappers.
- UI : `DashboardScreen` (route `/dashboard`) avec XP meter + streak card + défi hebdo + activity graph GitHub-style 12 semaines + badge gallery 4×4. `StreakBadge` compact intégré dans le header home.
- Ajout `flutter_markdown ^0.7.4+3` au pubspec pour le rendu markdown du content.

## Consequences

### Positives
- ✓ Fidélité au contenu source — l'utilisateur voit vraiment ce qu'il a capturé.
- ✓ Recherche sémantique drastiquement plus riche (tout le texte embedded, pas juste titre+résumé).
- ✓ Push-teaser plus qualitatif (hook tiré du contenu précis, pas d'un résumé générique).
- ✓ UI plus simple : 1 flux markdown au lieu de 3 sections séparées (steps/code/summary).
- ✓ Gamification renforce explicitement la **consultation** et **l'application** — les comportements qui meurent aujourd'hui.

### Négatives
- ✗ Tokens LLM output ≈ doublés par fiche (output ~1.5× plus long). Coût estimé ~0.0015 €/fiche (toujours ≪ NFR-004 0.05 €).
- ✗ Breaking change pour tout code existant qui référence `card.steps` ou `card.codeBlocks` — nettoyé dans cette même session.
- ✗ La gamification ajoute 6 fichiers domain + 6 data + 4 UI = +~16 fichiers à maintenir. Acceptable au vu de l'impact retention.

### Risques
- Le rendu markdown peut mal gérer des cas limites (tables, HTML brut) — mitiger via tests golden en Sprint 4.
- Les badges sont débloqués one-way (pas de retrait) — cohérent avec les standards gamification. Pas de gamification dette technique à long terme.
