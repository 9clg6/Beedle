# Brainstorming Session — Beedle

**Date :** 2026-04-15
**Participants :** Clement (porteur de projet) + Creative Intelligence (BMAD)
**Durée :** ~45 min
**Techniques appliquées :** Jobs-to-be-Done → Reverse Brainstorming → SCAMPER
**Objectif :** Cadrer le concept produit (A), les mécaniques d'activation (C), les risques (D), le catalogue de features (B).

---

## 1. Contexte

Clement consomme énormément de contenu tech sur son téléphone (Twitter, LinkedIn), fait de la veille IA, et capture via **screenshots** les contenus qui l'intéressent. Problème : ces screenshots **ne sont jamais revus**. Ils deviennent un cimetière dans la pellicule. Les outils de veille existants (Notion, Obsidian, Mymind, Readwise) sont **passifs** : si l'utilisateur n'y retourne pas, aucune valeur n'est extraite.

**Hypothèse produit :** une app mobile qui transforme ces screenshots en fiches structurées via OCR + IA, et qui **pousse activement** l'utilisateur à consommer/appliquer le contenu.

---

## 2. Concept produit

> **Beedle — la veille qui se rappelle à toi.**
>
> Tu balances tes screens de tweets, posts LinkedIn, tutos. L'IA les digère en fiches structurées (titre, résumé, étapes, code). L'app te relance avec des notifications contextuelles pour que ta veille devienne une vraie compétence — pas un cimetière de captures.

**Positionnement** : différencié vs Notion/Obsidian par le *push actif* ; différencié vs Readwise/Mymind par l'entrée screenshot-first et l'activation contextuelle.

**Cible primaire :** profils tech (veille IA, dev), extensible aux créatifs et à tout profil screenshoteur compulsif.

**Modèle économique pressenti :** abonnement (justifié par le coût IA backend + la valeur récurrente du push).

**Plateformes :** iOS + Android (Flutter).

**Deadline MVP :** 1 mois (fenêtre confortable, pas de pression).

---

## 3. Jobs-to-be-Done

### Jobs cœur MVP

- **J1 — Capture sans friction.** *Quand je vois un contenu intéressant en scrollant, je veux le capturer en 1 geste pour ne rien perdre sans rompre ma session.*
- **J2 — Digestion automatique.** *Quand je balance 1 ou 10 screens, je veux que l'IA les lise, les résume et m'en fasse une fiche propre sans intervention.*
- **J3 — Retrouver par vibe.** *Quand j'ai un besoin ponctuel, je veux retrouver une info sans me souvenir du mot-clé exact, par concept.*
- **J4 — Être poussé à consommer.** *Quand j'ajoute du contenu, je veux que l'app me rappelle activement de le lire/tester au bon moment.* **← différenciateur clé**

### Jobs V2

- **J5 — Valoriser ma veille** (partage social, threads générés à partir de fiches).
- **J6 — Ingestion par URL** (coller un lien = même traitement qu'une image).

### Contrainte technique (reclassée depuis une question user)

- **OCR local en 1re passe, LLM externe pour la digestion.** Baisse le coût IA par fiche de ~90 %. Condition de viabilité de l'abonnement.

---

## 4. Principes de design (issus de l'inversion des failure modes)

| # | Principe | Origine (failure inversé) |
|---|---|---|
| **P1** | **Deux boucles de push, jamais de notif générique.** **Push-teaser** (SC14) : contenu généré depuis une fiche, timing variable, sert la consommation. **Push-capture** (SC15) : rappel daily fixe d'importer, sert la capture. Combiné ≤ 2-3/jour max. | F1 — Notification fatigue |
| **P2** | **Home éditoriale.** Pas de liste chronologique. 1 suggestion du jour + 2-3 "à revoir". Le reste est caché derrière recherche/catégories auto. L'app a une opinion. | F4 — Feed panique |
| **P3** | **Recherche sémantique.** Embeddings pour retrouver par concept flou. Suggestions en cours de saisie. | F5 — Recherche qui ne retrouve rien |
| **P4** | **Zéro saisie manuelle.** L'IA titre, tag, catégorise, résume, extrait le code. L'utilisateur peut corriger *a posteriori*, jamais nommer *a priori*. | F8 — Trop d'étapes manuelles |
| **P5** | **Valeur ajoutée obligatoire.** Chaque fiche apporte ce que le screen n'a pas : résumé exécutif, niveau, temps d'exécution, étapes clarifiées, code prêt-à-coller. | F9 — Bibliothèque sans valeur ajoutée |

---

## 5. Périmètre MVP (8 features)

| Code | Feature | Pilier | Effort |
|---|---|---|---|
| **SC1** | **Android :** auto-import du dossier Screenshots en tâche de fond. **iOS :** import manuel depuis l'app (pas d'auto-import possible, compensé par SC15). | Capture | M |
| **SC5** | Share sheet iOS/Android (partager image ou texte depuis n'importe quelle app vers Beedle) | Capture | S |
| **SC2** | Fusion automatique multi-screens en 1 fiche cohérente (regroupement par proximité temporelle + similarité OCR) | Digestion | M |
| **SC10** | Zéro saisie manuelle + recherche sémantique (pas de tags/dossiers) | Surface | M |
| **SC11** | Home éditoriale : suggestion du jour + 2-3 "à revoir", pas de liste | Surface | S |
| **SC6-light** | Boutons par fiche : `[Ouvrir la source]` + `[Ouvrir avec ChatGPT/Claude]` (prompt pré-rempli) | Activation | S |
| **SC14** | **Push-teaser (intelligent).** Notifications locales contenu-based, générées depuis une fiche, 0-2/jour, timing calé sur habitudes. Sert la boucle *consommation* (J4). | Activation | M |
| **SC15** | **Push-capture (fixe).** Notification locale quotidienne à horaire fixe choisi par l'user : *"Tu as des contenus à importer aujourd'hui ?"*. Sert la boucle *capture* (J1). Compense l'absence d'auto-import sur iOS. | Capture | S |

**Stack implicite :** Flutter, OCR local (ML Kit ou Tesseract), LLM externe (GPT-4o-mini ou Claude Haiku en 1re passe, modèle plus puissant à la demande), stockage local + embeddings locaux (sqlite-vec ou équivalent) pour garder coûts bas et privacy forte.

---

## 6. Backlog V2 (features différées)

- **SC3** — Note vocale au moment de la capture → contexte injecté dans le prompt IA.
- **SC4** — Streak / gamification Duolingo-style.
- **SC6-full** — "Teste maintenant" avec prompts pré-câblés par type de contenu.
- **SC7** — Format flashcard swipable 20 sec pour transports.
- **SC8** — Génération de posts LinkedIn / threads depuis une fiche.
- **SC9** — Curations publiques partageables ("Mes 20 astuces Claude Code").
- **SC12** — Re-surfaçage contextuel ambiant (détection de tâche en cours → fiche pertinente remontée).
- **SC13** — Interface vocale ("Beedle, c'était quoi le truc sur les hooks ?").
- **J5** — Valorisation / partage social.
- **J6** — Ingestion par URL.

---

## 7. Risques & failure modes

| Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|
| **R1 — Fiches IA plates.** Si le prompt de digestion produit du résumé générique, P5 s'effondre et par effet domino P1 (pas de teaser sans bon contenu). | Moyenne | **Létal** | Prototyper le prompt en standalone (script isolé) sur 15-20 vrais screens du porteur **avant** toute ligne de Flutter. Itérer jusqu'à "j'ai envie de consulter". |
| **R2 — Coût IA non maîtrisé.** 100 fiches/mois × 3 appels = abonnement pas rentable. | Moyenne | Haut | Pipeline OCR local + LLM économique pour digestion, modèle premium à la demande uniquement. |
| **R3 — Limites OS sur le push.** iOS/Android restreignent les notifs contextuelles (Doze, batterie). | Haute | Moyen | Notifications locales (pas push server) + timing intelligent max 1-2/jour + créneaux calmes détectés. |
| **R4 — SC1 iOS.** Pas d'accès continu à Photos en background sur iOS. | Haute | *Mitigé* | Accepté : iOS = import manuel depuis l'app, compensé par SC15 (daily import reminder). Android = FileObserver direct. |
| **R5 — Concurrence.** Mymind / Readwise peuvent ajouter le push IA. | Moyenne | Moyen | Sprint vite, construire un moat sur la qualité du prompt + UX mobile-native. |
| **R6 — Friction d'ajout.** Si capture reste manuelle, l'app meurt en 2 semaines. | *Mitigée* | Létal | SC1 + SC5 au MVP → pipeline de capture sans ouvrir l'app. |

---

## 8. Insights clés (7)

### Insight 1 — "Push, pas pull" est le positionnement
Beedle ne se compare pas à Notion/Obsidian/Mymind sur le stockage, mais sur **qui agit en premier**. Si l'utilisateur doit venir à l'app, Beedle = Notion en moins bien. Tout le produit doit être conçu autour de ce principe.

**Source :** J4, F9, P1, P2. **Impact :** Haut | **Effort :** Haut

### Insight 2 — La notification n'est pas un canal, c'est le produit
La notif de rappel classique ("tu as 3 fiches à lire") = mort. La notif contenu-based ("Automatise ton Figma avec Claude en 2 min") = drogue. **Beedle se consomme principalement depuis la notif**, pas depuis l'app ouverte. Ça change la hiérarchie du design.

**Source :** F1 (inversé), P1, SC14. **Impact :** Haut | **Effort :** Moyen

### Insight 3 — La qualité du prompt de digestion est le goulet d'étranglement #1
Tout repose sur la qualité de la fiche générée. Fiche plate → teaser plat → mute → mort. **Le MVP technique n'est pas l'app, c'est le prompt.** À prototyper en premier, hors Flutter, sur des données réelles.

**Source :** R1, P5. **Impact :** **Létal** | **Effort :** Faible (itérable rapidement)

### Insight 4 — Zéro saisie utilisateur est une décision radicale de différenciation
Notion/Obsidian exigent tags, dossiers, hiérarchie. Beedle = rien. Tout auto + recherche sémantique. Ça simplifie l'UX et surtout ça **supprime la friction post-capture** qui tue les systèmes PKM grand public.

**Source :** P4, SC10. **Impact :** Haut | **Effort :** Moyen

### Insight 5 — OCR local + LLM externe = condition d'existence de l'abonnement
Si chaque fiche = 3 appels GPT-4 premium, le coût marginal tue la marge. Pipeline hybride : extraction texte gratuite on-device, IA externe uniquement pour structurer et générer. Décision architecturale **tactique**, pas esthétique.

**Source :** Contrainte J7 reclassée, R2. **Impact :** Haut | **Effort :** Faible

### Insight 6 — La home éditoriale est une rupture vs tous les concurrents
Apple Photos / Notion / Readwise ouvrent sur une liste. Beedle ouvre sur **une seule chose**. C'est une décision forte, légèrement inconfortable, mais cohérente avec le principe push : l'app **décide pour toi**.

**Source :** F4 (inversé), SC11, P2. **Impact :** Moyen | **Effort :** Faible

### Insight 7 — L'abonnement est viable parce que la valeur est récurrente et active
Un outil de stockage ne justifie pas un abonnement (one-shot). Un outil qui **te rappelle et t'active** produit de la valeur chaque semaine → rétention → abonnement tenable. Cohérence économique : sans push actif, pas d'abonnement justifiable.

**Source :** J4, positionnement. **Impact :** Haut | **Effort :** N/A (conséquence stratégique)

---

## 9. Questions ouvertes pour la phase architecture

- Quel OCR local choisir : ML Kit (Google, gratuit, iOS+Android) vs Tesseract (offline complet mais moins précis) vs Apple Vision (iOS only, excellent) ?
- Quel LLM pour la digestion : GPT-4o-mini vs Claude Haiku 4.5 vs Gemini Flash ? Benchmark sur 15 screens réels à faire.
- Stockage + embeddings : 100 % local (sqlite-vec, privacy) vs backend (sync multi-device, mais coût + RGPD) ?
- SC1 iOS : Share Extension only ou proposer une config Shortcut auto qui copie Screenshots → Beedle en temps réel ?
- Gestion des captures multi-screens (SC2) : heuristique de clustering (timestamp + similarité) ou LLM qui décide "c'est la suite du screen d'avant" ?
- Timing intelligent des notifs (SC14) : quels signaux utiliser sans demander de permission sensible (activité app, heure, lockscreen usage) ?

---

## 10. Statistiques

- **Idées générées :** 14 (SC1-SC14) + 7 jobs + 9 failure modes + 5 principes = ~35 éléments structurés
- **Jobs MVP :** 4 (+ 1 contrainte tech)
- **Features MVP :** 8
- **Backlog V2 :** 10
- **Risques identifiés :** 6
- **Insights clés :** 7
- **Techniques appliquées :** 3 (JTBD, Reverse Brainstorming, SCAMPER)

---

## 11. Prochaines étapes recommandées

### Immédiat (avant de coder)
1. **Prototype du prompt de digestion** — script standalone, 15-20 vrais screens, itération jusqu'à qualité "j'ai envie de lire la fiche". **C'est le vrai MVP technique.**

### Workflow BMAD
2. **`/bmad:product-brief`** — formaliser le brief produit avec ce matériau (30 min au lieu de 40, la plupart des réponses sont déjà là).
3. **`/bmad:prd`** — PRD Level 2, features MVP détaillées avec acceptance criteria.
4. **`/bmad:architecture`** — trancher les 6 questions ouvertes de la section 9.
5. **`/bmad:sprint-planning`** → stories → dev.

---

*Session générée par BMAD Method v6 — Creative Intelligence*
