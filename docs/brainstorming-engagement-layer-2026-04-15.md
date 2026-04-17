# Brainstorming Session — Engagement Layer ("Beedle's Voice")

**Date** : 2026-04-15
**Objectif** : Concevoir une couche d'engagement sur la Home qui transforme les cards passives (stockées) en interactions actives (consultation, test, re-engagement), via 3 surfaces : streak card, terminal-style message card, push notifications contextuelles.
**Contexte** : Beedle post-redesign CalmSurface, pipeline LLM opérationnel (OpenAI gpt-4o-mini via Worker Cloudflare), screenshots ingérés → cards Markdown. Le positionnement est "la veille qui se rappelle à toi". Le problème à résoudre est celui de toute app read-it-later : éviter que les cards deviennent un cimetière.

## Techniques appliquées

1. **Mind Mapping** — exploration exhaustive de l'arbre "Beedle's Voice"
2. **SCAMPER** — mutation et combinaison des 3 idées seed
3. **Reverse Brainstorming** — stress-test contre les anti-patterns (Duolingo disease)

---

## Reframing — "Beedle's Voice"

Les 3 idées initiales (streak card, chat card home, notifications) sont **les surfaces d'une seule voix** : la voix IA de Beedle qui s'exprime à partir du contenu que l'user capture.

**Insight architectural clé :** un seul appel LLM à la digestion peut produire, en plus de `summary` et `fullContent`, **une batterie de messages terminal + hooks push pré-calculés**, stockés et joués plus tard. Coût marginal ~50 tokens output, 0 input. Pas de cron, pas d'agent second. La faisabilité économique ET technique du feature est débloquée.

---

## Idées générées (44 total)

### Catégorie 1 — Génération (WHEN parle la voix ?)

- À l'ingestion d'une card → LLM produit 3-6 messages + 2-3 push hooks en batch
- Au boot quotidien → scheduler service pioche dans le pool pré-calculé
- Sur silence (J+3 sans ouverture) → message compatissant, jamais culpabilisant
- Sur streak milestone (7, 30, 100 jours) → reconnaissance sobre
- Sur streak cassé → message de remise en route, sans jugement
- Sur re-découverte (card > 30j, pas vue) → "Guillaume attendait"

### Catégorie 2 — Terminal Card (surface Home)

- Monospace dark inverse (ink background) sur fond Aurora warm
- Latest message prominent, historique fade-up (opacity gradient)
- Typing animation discrète (24ms/char, ease-standard)
- Tap → expand drawer avec historique complet (bottom sheet blur σ 24)
- Hauteur fixe : 4-6 lignes visibles
- Police : Geist Mono (par défaut) ou VT323 (variante CRT)
- Timestamp terminal-style : `[18:47]` en préfixe gris neutral.5
- 1ère ligne = streak : `[STREAK] day 12`
- Fade-out sur message obsolète (>24h) remplacé par nouveau

### Catégorie 3 — Push Notifications (surface OS)

- `flutter_local_notifications` (déjà dans pubspec) + scheduling service
- Messages pré-générés au digest, stockés avec `scheduledAt` calculé
- 1 push/jour max en rythme de croisière (slider user : 0-3)
- Créneaux : 8h00 (morning hook) ou 20h00 (evening read)
- Jamais entre 22h et 8h
- Deep-link vers `CardDetailRoute` précis
- Types : reminder J+1, test-prompt J+3, rediscovery J+30
- Signature de l'auteur : "Sthiven R. · @Sthiven_R — ton prompt attend"
- Back-off si silence 3+ jours (respect, pas spam)
- Silent mode / Zen mode : toggle off total

### Catégorie 4 — Tonalité (voice guidelines)

- Tutoie (user est solo)
- Observationnel, jamais exclamatif
- Zéro émoji (CalmSurface anti-pattern §6)
- ≤ 80 chars (tient sur 1 ligne terminal + notif OS)
- Présent tense, neutre
- Référence Apple-narrator calme, PAS Duolingo-mom
- Name-drop systématique : auteur de la card, source, platform
- 2 formats : `short` (≤ 40 chars pour push) + `long` (≤ 120 pour terminal)

### Catégorie 5 — Silent mode / Respect

- Settings → Voice : toggles granulaires (terminal, push, streak, quota slider)
- Respect `Do Not Disturb` / Focus iOS
- No-notif window 22h-8h
- Back-off après 3 jours d'absence user
- Pas de push avant J+1 de l'onboarding
- Zen mode : zéro push, zéro badge, juste terminal passif
- Opt-out par type : "je veux des reminders mais pas des reflections"

### Catégorie 6 — Data model & services

- `CardEntity` inchangé
- Nouveau `EngagementMessage { uuid, cardUuid, content, type, format, delayDays, scheduledAt?, shownAt? }`
- Nouveau `EngagementMessageRepository` + data source ObjectBox
- Nouveau `EngagementSchedulerService` (domain) — picks from pool, resolves `scheduledAt`
- Nouveau `NotificationService` (data layer) wraps `flutter_local_notifications`
- Ajout au LLM JSON schema : `engagementMessages: [{ content, type, format, delayDays }]`
- Types enum : `reminder | invite | observation | connection | reflection`

### Catégorie 7 — SCAMPER variantes

- **Substitute** streak par "days alive" (Tamagotchi-style)
- **Combine** terminal + streak en 1 seul widget (1ère ligne = streak)
- **Combine** push + auteur (push signée, pas de l'app)
- **Adapt** ton compilateur : `[INFO] 3 cards ingested`
- **Modify** tempo : rotation toutes les 4h dans terminal
- **Put to other uses** : messages stockés → Weekly Digest exportable (Pro feature)
- **Eliminate** notifs OS (silent-first) pour users zen
- **Reverse** : l'app écoute (pattern analytics) au lieu de parler
- **Reverse** : badge icône app rouge au lieu de notif OS

---

## Key Insights (5)

### Insight 1 — **One digestion = all engagement content**

- **Impact** : High · **Effort** : Medium
- **Sources** : Mind mapping (Génération) + Reverse (règle 1)
- L'appel LLM actuel produit déjà `summary`, `fullContent`, `tags`, etc. On ajoute `engagementMessages[]` et `pushHooks[]` au JSON schema, ~50 tokens output en plus. 3-6 messages + 2-3 push pré-calculés par card, stockés ObjectBox. **Pas de job récurrent, pas d'agent séparé.** C'est LA décision architecturale qui rend la feature viable.

### Insight 2 — **Le "Tamagotchi" est un ton, pas un personnage**

- **Impact** : High · **Effort** : Low (prompt engineering)
- **Sources** : Reverse (règles 4-5) + Mind mapping (Tonalité)
- Aucune mascotte, aucun avatar, aucun nom propre. Juste une voix stable via system prompt. Le Tamagotchi émerge de : spécificité (name-drop auteur+card), constance du ton (observationnel), absence de culpabilisation. Anti-Duolingo par construction. Cohérent avec le manifeste CalmSurface (pas d'illustration isométrique, pas d'emoji).

### Insight 3 — **Terminal Card = nouvelle surface signature CalmSurface**

- **Impact** : High · **Effort** : Medium
- **Sources** : Mind mapping (Surface 1) + SCAMPER (Adapt ton)
- Widget monospace dark inverse sur Aurora warm → contraste maximal, unique visuellement. C'est un **log**, pas un feed. Cohérent famille Doto/VT323. Probablement la future "carte de visite" visuelle (screenshot App Store).

### Insight 4 — **Quota dur & back-off : respect = rétention**

- **Impact** : High · **Effort** : Low
- **Sources** : Reverse (règles 3, 11) + Mind mapping (Silent mode)
- 1 push/jour max. Back-off après 3 jours d'absence. Rien entre 22h-8h. Settings → Voice granulaires. Counter-intuitif mais : **un user qui peut couper facilement garde l'app**. Les apps qui étouffent se désinstallent.

### Insight 5 — **Read-only explicite = calme préservé**

- **Impact** : Medium · **Effort** : Low (absence d'une feature)
- **Sources** : User feedback Q1 + Reverse (règles 5-6)
- Le terminal n'accepte pas d'input. Pas de réponse utilisateur. Évite tous les trade-offs IA-chat (hallucinations, latence, coût). Préserve le calme (pas de pression de répondre). Force le produit à être une surface d'**observation**, pas une conversation — très fort UX-wise.

---

## Statistiques

- **Total idées brutes** : ~44
- **Catégories** : 7
- **Key insights** : 5
- **Anti-patterns formalisés** : 12
- **Techniques appliquées** : 3 (Mind Mapping, SCAMPER, Reverse Brainstorming)

---

## Recommended Next Steps

### Étape 1 — Tech Spec (recommandée immédiatement)

Rédiger une spec technique focalisée sur :

1. Schéma de données `EngagementMessage` + migration ObjectBox
2. Extension du JSON schema LLM + update du system prompt
3. Nouveau `EngagementSchedulerService` (domain layer)
4. Nouveau `NotificationService` (data layer, wraps `flutter_local_notifications`)
5. Terminal Card widget (presentation) + intégration Home
6. Settings → Voice (sub-screen avec 4 toggles + 1 slider)
7. Migration data — quid des cards déjà ingérées ? Option A : re-digest batch ; Option B : skip, nouvelles cards only.

→ Lance `/bmad:tech-spec`

### Étape 2 — Prototype visuel Terminal Card

Avant de toucher au backend : prototype du Terminal Card sur un écran dev isolé avec des messages mockés. Permet de valider la ligne de police (Geist Mono vs VT323), le contraste (ink vs Aurora), la typing animation, le comportement d'expand. Budget : 2h.

### Étape 3 — Validation coût LLM

Mesurer sur 10 digestions réelles le delta tokens avec les 2 nouveaux champs. Objectif : confirmer < 100 tokens output additionnel. Si > 200 → revoir le schema (moins de messages, format plus court).

---

## Ouvertures

- **Weekly Digest** — si on a un pool de messages stockés, on peut générer un résumé hebdo automatique (bonus Pro) basé sur les cards vues/testées + patterns. SCAMPER "Put to other uses".
- **Pattern analytics** — l'app peut surfacer des méta-observations ("80% de tes captures sont en soirée", "Tes cards Claude ont 3× plus d'ouvertures") sans LLM, juste sur les données ObjectBox. SCAMPER "Reverse".
- **Author threading** — quand plusieurs cards partagent un auteur, lien automatique entre elles ("3 cards de Sthiven cette semaine, un pattern"). Nécessite de détecter l'auteur au parse — déjà partiellement fait via la blockquote Markdown dans le nouveau prompt.

---

*Generated by BMAD Method v6 — Creative Intelligence*
*Session duration : ~25 min*
