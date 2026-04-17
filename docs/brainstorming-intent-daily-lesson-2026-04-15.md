# Brainstorming Session — Intent Taxonomy + Daily Lesson

**Date** : 2026-04-15
**Objectif** : Enrichir la couche Engagement (déjà livrée) avec une taxonomie d'intent sur les cards (apply / read / reference) et une surface "Daily Lesson" pour les cards actionnables. Préparer le terrain V2 (platform + AI curator).
**Related docs** : [`brainstorming-engagement-layer-2026-04-15.md`](./brainstorming-engagement-layer-2026-04-15.md) · [`tech-spec-engagement-layer-2026-04-15.md`](./tech-spec-engagement-layer-2026-04-15.md) · [`DESIGN.md`](./DESIGN.md)

## Techniques appliquées

1. **Mind Mapping** — arborescence V1 (intent + daily lesson) + ponts V2
2. **SCAMPER** — mutation/combinaison des deux idées
3. **Reverse Brainstorming** — anti-patterns Daily Lesson

---

## Reframing — V1 vs V2

| Horizon | Feature | Statut de cette session |
|---------|---------|-------------------------|
| V1 (ce sprint) | **A. Intent taxonomy hybride** — `apply`/`read`/`reference` détecté par LLM + override user | ✅ Specified below |
| V1 (ce sprint) | **B. Daily Lesson** — push matinale + écran stylé, cards `apply` non testées | ✅ Specified below |
| V2 (roadmap) | **C. Creator platform** — auth, profils publics, abonnement à @handle, feed syndiqué | 🗺️ Sketched only |
| V2 (roadmap) | **D. AI curator feed** — l'user configure des sources (RSS / Twitter / YouTube), Worker cron digère en cards | 🗺️ Sketched only |

**Vision 12 mois** : Beedle = PKM solo (usage privé) **+** plateforme de veille automatisée par abonnement à des créateurs humains ou agents IA.

**Insight structural clé** : C et D partagent la même infra backend (feed service, auth, syndication). Coder `intent` dès V1 prépare le filtering cross-feed V2 sans surcoût.

---

## Idées générées (52 total)

### Catégorie 1 — Intent taxonomy (A)

- **Enum 3 valeurs** (recommandé) : `apply`, `read`, `reference`
- Alternative 4 valeurs : + `inspire` (quote/citation courte)
- Alternative 2 axes binaires : `actionable` + `technical` (plus riche, moins visuelisable)
- **Default** : `read` (safe fallback pour cards pré-feature)
- Détection LLM à la digestion (nouveau field dans JSON schema + règles prompt)
- Override user :
  - Tap intent badge sur CardDetail → bottom sheet 3 chips
  - Long-press sur CardGlassTile Home → context menu rapide
  - Flag `intentOverridden: bool` dans CardEntity → LLM ne re-classe pas au re-digest (fusion)
- **Badges visuels** discrets (Lucide, stroke 1.5) :
  - `apply` → PlayCircle ember
  - `read` → BookOpen neutral.7
  - `reference` → FileText neutral.5
- **Filter Home** : segmented control "À tester" / "À lire" / "Toutes" au-dessus de la liste
- **Filter Search** : chip filter par intent
- **Comportements downstream** :
  - Voice engagement — types adaptés par intent (`apply` → invite/reminder dominant, `reference` → quasi silencieux)
  - Daily Lesson — source UNIQUEMENT `apply`
  - Push teaser — exclut `reference`
  - Search ranking — boost `apply` si query contient verbe d'action

### Catégorie 2 — Daily Lesson (B)

- **Push OS matinale** optionnelle (créneau configurable défaut 8h30, jitter ±5min)
- Payload `beedle://lesson` → écran dédié (pas deep-link direct card)
- **Alternative persistent** : bloc sur Home Screen au-dessus du Terminal Voice (default, sans push)
- **Alternative widget iOS Home Screen** : carré avec lesson du jour (V1.5, pas ce sprint)
- **Algorithme sélection** :
  - Pool : cards `intent=apply`
  - Filter 1 : `testedAt == null`
  - Filter 2 : pas sélectionnée dans les 3 derniers jours
  - Sort : recency DESC (fresh wins)
  - Fallback : card `apply` la plus anciennement vue si tout testé
- **Écran Daily Lesson** minimal :
  - Header `[TODAY'S LESSON]` Doto orange
  - Titre (display.md)
  - Summary (body.lg neutral.7)
  - `primaryAction` extraite (1 action concrète, ≤ 80 chars, verb-starter)
  - CTA primary : "Commencer" → CardDetail avec flag `fromLesson`
  - CTA ghost : "Remettre à demain"
  - Swipe up dismiss → skip du jour
- **Extension LLM** : nouveau field `primaryAction: String?` (null si intent != apply)
- **Respect quotas** :
  - Respect DND system iOS
  - Skip si `voiceZenMode == true`
  - Skip si `voicePushEnabled == false` (pour le mode push)
- **Skip streak** : 3 skips consécutifs / semaine max ; au-delà auto-archivée du pool
- **Mark testedAt** au tap "C'est fait" — atomique avant animation

### Catégorie 3 — SCAMPER mutations

- **Combine** : Daily Lesson réussie → +1 bonus streak "lesson done" (double incitation)
- **Combine** : Terminal Voice affiche `[DONE] lesson applied.` pendant 24h post-testedAt
- **Adapt** (Pocket "Just One More") : après mark tested, suggérer la prochaine `apply` ("4 autres attendent")
- **Adapt** (Shortcuts morning ritual) : push batch matinal = 1 lesson + 3 suggestions `read`
- **Modify** : tempo 1-7/semaine slider user (pas imposer quotidien)
- **Put to other uses** : `reference` cards = matière export Obsidian/Notion
- **Put to other uses** : `apply` + testedAt log = "tech diary" exportable (bonus Pro)
- **Eliminate** : push OS en opt-in seulement, bloc Home persistent en default (plus calme)
- **Reverse** : user swipe sa liste demain la veille (Tinder de l'apprentissage)
- **Reverse** : push le soir ("Voici ce que tu peux tester demain") plutôt que le matin

### Catégorie 4 — Anti-patterns identifiés

Voir section Reverse pour la liste complète.

### Catégorie 5 — V2 bridges (notes préparatoires)

- `intent` devient un filter primaire dans les feeds syndiqués V2
- `primaryAction` = pattern "content contract" que les créateurs V2 devront respecter
- L'UI `[TODAY'S LESSON]` préfigure les "Daily Drops" de créateurs V2
- La Daily Lesson algorithme peut être étendu V2 : "Lesson from @untel" si user suit des créateurs

---

## Key Insights (5)

### Insight 1 — **Intent = multiplicateur de l'existant**

- **Impact** : High · **Effort** : Low
- **Sources** : Mind Mapping + Q1 hybrid confirmé
- Un seul nouveau field `intent` change tous les comportements downstream : filter Home, Voice engagement types, Daily Lesson pool, push exclusion, search ranking. Petit add, gros ripple. Default `read` = backward-compat automatique.

### Insight 2 — **Daily Lesson ≠ Voice Terminal**

- **Impact** : High · **Effort** : Medium
- **Sources** : Mind Mapping + SCAMPER Combine
- Voice = **ambient, observationnel, low-pressure** (déjà livré).
- Daily Lesson = **focal, actionnable, 1 moment/jour**.
- Ne PAS les fusionner. Ce sont 2 modes UX distincts, 2 niveaux d'engagement. Leur tension = richesse du produit.

### Insight 3 — **`primaryAction` = extension LLM marginale, déblocage UX énorme**

- **Impact** : High · **Effort** : Low
- **Sources** : Mind Mapping + Reverse règles 7-8
- Au même appel LLM (digestion), on ajoute `primaryAction: String?` (≤ 80 chars, verb-starter, null si intent != apply). Overhead ~30 tokens out. Débloque intégralement l'écran Daily Lesson.

### Insight 4 — **Push OS en opt-in, bloc Home en default**

- **Impact** : Medium · **Effort** : Low
- **Sources** : SCAMPER Eliminate + user retention psychology
- Livrer 2 modes :
  - **Default** : bloc Today's Lesson persistent sur la Home (silencieux)
  - **Opt-in** : push matinale via Settings → Voice → "Push matinal"
- User qui peut couper facilement reste plus longtemps. Par défaut silencieux, notif pour ceux qui veulent.

### Insight 5 — **Intent prépare l'architecture V2 (platform) à coût zéro**

- **Impact** : Strategic High · **Effort** : 0 (inclus dans V1)
- **Sources** : Q3 + Q4 cross-reference
- En V2, subscribers voudront filtrer par intent les feeds de créateurs ("prompts only from @untel"). Coder `intent` dès V1 — même pour usage solo — débloque cette feature social sans redev. Zero cost, high strategic payoff.

---

## Statistiques

- **Total idées brutes** : ~52
- **Catégories** : 5
- **Key insights** : 5
- **Anti-patterns formalisés** : 10
- **Techniques appliquées** : 3

---

## Recommended Next Steps

### Étape 1 — Tech Spec V1 (immédiat, recommandé)

Rédiger la spec technique qui couvre :

1. **Data model** : ajout `intent` + `intentOverridden` + `primaryAction` + `testedAt` (existe déjà) à `CardEntity` et `CardLocalModel`
2. **LLM schema extension** : `intent` enum + `primaryAction` string nullable (règles prompt)
3. **Intent override** : bottom sheet sur CardDetail + long-press context menu sur CardGlassTile
4. **Filter segmented control** : Home + Search, avec state persisté
5. **Daily Lesson service** (domain) : algo sélection + scheduling + mark testedAt
6. **Écran `/today`** + route AutoRoute + deep-link `beedle://lesson`
7. **Bloc Today Home** (default) + push opt-in Settings
8. **Extension Voice settings** : toggle "Daily Lesson push" + hour picker

→ Run `/bmad:tech-spec`

### Étape 2 — V2 Product Brief (roadmap, pas immédiat)

Avant de commencer V2 (creator platform + AI curator), formaliser un product brief séparé :

- Market research (Beehiiv, Substack, Refind, Readwise)
- Auth strategy (Supabase vs Firebase vs custom)
- Monetization model (Pro = follows, ad-free, etc.)
- V2 timeline (Q3 2026 earliest)

→ Noté pour plus tard, pas ce brainstorming.

### Étape 3 — Validation coût LLM

Ajouter 2 champs au LLM schema = mesurer sur 10 digestions le delta tokens. Cible < 50 tokens output additionnels.

---

## Ouvertures (notes)

- **Intent auto-detect par usage** — si user tap CTA "Commencer" sur Daily Lesson ET marque `testedAt`, c'est un signal fort que l'intent détecté était juste. Train data pour fine-tune potentiel plus tard.
- **Time-to-apply metric** — médiane "temps entre digestion et testedAt" par type de card. Indicateur produit riche.
- **Intent streaks** — "tu testes 5 cards `apply` d'affilée" → badge sobre dans Dashboard.
- **Inter-intent connections** — LLM détecte qu'une card `reference` sert de source à une card `apply` → lien visible.

---

*Generated by BMAD Method v6 — Creative Intelligence*
*Session duration : ~20 min*
