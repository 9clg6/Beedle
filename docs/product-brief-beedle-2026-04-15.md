# Product Brief: Beedle

**Date :** 2026-04-15
**Auteur :** Clement
**Version :** 1.0
**Type de projet :** mobile-app (Flutter, iOS + Android)
**Niveau BMAD :** 2 (5-15 stories)
**Source amont :** [`docs/brainstorming-beedle-2026-04-15.md`](./brainstorming-beedle-2026-04-15.md)

---

## Executive Summary

Beedle est une application mobile (iOS + Android, Flutter) qui transforme le chaos de screenshots de contenu tech en fiches structurées par IA, puis **pousse activement** l'utilisateur à les consommer via des notifications locales contenu-based. Destinée d'abord aux profils tech (veille IA, développeurs, builders) puis extensible aux créatifs, elle résout un problème universel et quotidien : les screenshots capturés avec enthousiasme mais jamais revus. Promesse : *"la veille qui se rappelle à toi"* — un positionnement radicalement différent des outils passifs type Notion, Obsidian, Mymind ou Readwise.

---

## Problem Statement

### Le problème

L'utilisateur tech moderne consomme énormément de contenu sur mobile (Twitter/X, LinkedIn, newsletters IA). Quand il voit une astuce, un tuto, une ressource utile, son réflexe est le **screenshot** — geste rapide, sans friction, gratifiant. Mais ces screenshots finissent dans un dossier Photos qu'il ne revisite **jamais**. La veille est **capturée** mais jamais **digérée**, jamais **retrouvée**, jamais **appliquée**.

**Exemple concret (vécu par le porteur).** Clement capture 5-10 astuces techniques/jour sur son téléphone. Il ne se souvient pas de ce qu'il a sauvegardé hier. Quand il en a besoin, il retourne chercher sur Google ou Twitter — souvent sans retrouver la source originale. Le screenshot est mort.

**Les outils existants ratent le problème.** Notion, Obsidian, Readwise, Mymind exigent tous que l'utilisateur *y retourne activement*. Or c'est précisément la friction qui fait que la deuxième étape (consulter) ne se produit jamais. *"Si je ne regarde pas Notion, je ne suis pas plus avancé que sans rien."*

### Why Now?

Trois convergences rendent le moment unique :

1. **L'IA générative** atteint une qualité de résumé/structuration qui permet de transformer un screen flou en fiche exploitable, à coût marginal faible (GPT-4o-mini, Claude Haiku 4.5, Gemini Flash).
2. **L'OCR on-device** (Apple Vision, Google ML Kit) est devenu quasi-parfait et gratuit, rendant économiquement viable un pipeline hybride OCR local + LLM cloud.
3. **Le volume de contenu tech mobile explose** avec l'écosystème IA (Claude Code, ChatGPT, Cursor, Figma AI...) — une audience vit le problème quotidiennement et n'a pas d'outil adapté.

### Impact si non résolu

L'utilisateur continue à perdre ~100 % de la valeur de sa veille. La capture devient un rituel rassurant mais stérile — l'illusion de faire sa veille sans jamais la digérer. Au niveau communauté : les connaissances tech s'accumulent en silence sans se transformer en pratiques, ralentissant la propagation des outils et méthodes.

---

## Target Audience

### Utilisateurs primaires

Profils **tech-savvy, veilleurs mobile-first** (25-45 ans) :

- Développeurs / ingénieurs logiciels qui veulent appliquer les dernières techniques IA/outil
- Product people et designers tech qui suivent les tendances
- Entrepreneurs et builders en veille IA / produit
- Utilisateurs intensifs de Claude, ChatGPT, Cursor, GitHub Copilot

**Comportements caractéristiques :**
- Forte consommation Twitter/X, LinkedIn, newsletters
- Capture compulsive via screenshot (volume : plusieurs par jour)
- Utilisation active d'IA pour leur travail
- Frustration avec les outils PKM (Notion, Obsidian) jugés trop lourds et passifs

### Utilisateurs secondaires

- Créatifs (designers, rédacteurs, vidéastes) qui capturent références visuelles et textuelles
- Étudiants tech/design qui veulent convertir leur veille en apprentissage
- Tout « screenshoteur compulsif » vivant le même rituel capture-sans-consultation

### Besoins utilisateurs (top 3)

1. **Capturer sans friction** — préserver le rituel existant : le screenshot
2. **Digestion automatique** — ne pas avoir à trier, tagger, titrer, résumer
3. **Être poussé à consommer** — sinon le cycle précédent se répète

Le besoin « retrouver par concept flou » (J3) est complémentaire mais n'est pas le déclencheur d'achat — le déclencheur est la douleur de la veille inerte.

---

## Solution Overview

### Solution proposée

Une application mobile Flutter (iOS + Android) articulée sur **4 piliers** :

1. **Capture** — auto-import Android (FileObserver), import manuel iOS, share sheet universel
2. **Digestion** — pipeline OCR local (ML Kit / Apple Vision) + LLM externe (modèle économique) produisant une fiche structurée : titre, résumé exécutif, étapes, code extrait, niveau, temps d'exécution
3. **Surface** — home éditoriale (1 « suggestion du jour » + 2-3 « à revoir », pas de liste) · recherche sémantique par embeddings locaux
4. **Activation** — deux boucles de notifications locales distinctes : **push-teaser** contenu-based (consommation, variable) + **push-capture** fixe quotidienne (import)

### Features clés (MVP, 8 items)

- **SC1 — Ingestion screenshots** : auto-import Android (tâche de fond), import manuel iOS (compensé par SC15)
- **SC5 — Share sheet** iOS + Android (image ou texte depuis n'importe quelle app)
- **SC2 — Fusion multi-screens** : regroupement automatique en 1 fiche cohérente (proximité temporelle + similarité OCR)
- **SC10 — Zéro saisie manuelle** + recherche sémantique (pas de tags, pas de dossiers)
- **SC11 — Home éditoriale** : 1 suggestion du jour, pas de feed chronologique
- **SC6-light — Boutons d'action** par fiche : `[Ouvrir la source]` + `[Ouvrir avec ChatGPT/Claude]` (prompt pré-rempli)
- **SC14 — Push-teaser** : notifications locales contenu-based, générées depuis une fiche, 0-2/jour, timing calé sur habitudes
- **SC15 — Push-capture** : notification locale quotidienne fixe à horaire choisi — *« Tu as des contenus à importer aujourd'hui ? »*

### Proposition de valeur

> **« La veille qui se rappelle à toi. »**
>
> Beedle transforme ton chaos de screenshots tech en une bibliothèque vivante qui te pousse à l'utiliser. Tu balances, l'IA digère, et l'app **te relance** avec des notifications contextuelles pour que ta veille devienne une vraie compétence — pas un cimetière de captures.

**Différenciateurs :**
- vs Notion/Obsidian : push actif, pas de hiérarchie manuelle, mobile-native
- vs Readwise/Mymind : entrée screenshot-first, activation contextuelle par l'IA, pas juste du save-for-later

---

## Business Objectives

### Objectifs (SMART)

- **Lancer un MVP public** iOS + Android dans les stores **d'ici ~2 mois** (horizon 2026-06-15).
- **Valider un product-market fit personnel** en mois 1 : le porteur utilise réellement l'app au quotidien.
- **Adopter un modèle freemium + trial** : essai gratuit (7-14 jours à définir) puis Pro à 9 €/mois (à A/B tester post-launch) avec plan annuel à 59-69 €/an pour réduire le churn.
- **Pas d'objectifs business chiffrés à ce stade** — projet perso / side project, validation qualitative avant toute ambition de scale.

### Métriques de succès

**Personnels (MVP, fin mois 1) — usage par le porteur :**
- Consultation de fiches : ≥ 4×/semaine
- Application réelle d'astuces : ≥ 1/semaine
- Clics sur notification (teaser) : ≥ 3/semaine

**Produit (post-launch, à instrumenter) :**
- Taux d'imports (auto vs manuel) par OS
- Taux de complétion du pipeline de digestion (imports → fiches générées)
- CTR des push-teasers (clics / notifs envoyées)
- Taux de recherches avec résultat jugé utile

**Business (post-launch, à valider) :**
- Conversion trial → paid
- Churn mensuel
- MRR
- DAU / MAU ratio (indicateur d'activation réelle)

### Valeur business

- **Court terme** : side project qui valide un besoin réel, dont le porteur est lui-même l'utilisateur n°1.
- **Moyen terme** : marché naturel sur l'écosystème tech/veille IA en croissance rapide.
- **Long terme** : extension aux créatifs et profils non-tech, potentiel plan équipe (V2+).

---

## Scope

### In Scope (MVP v1)

- Les **8 features MVP** listées en section Solution.
- **5 principes de design** : P1 Push en teaser · P2 Home éditoriale · P3 Recherche sémantique · P4 Zéro saisie manuelle · P5 Valeur ajoutée obligatoire par fiche.
- **Pipeline hybride** OCR on-device + LLM externe économique.
- **Stockage 100 % local** (sqlite + embeddings locaux, type sqlite-vec) — privacy forte, pas de compte utilisateur.
- **Freemium + trial** (structure paywall à finaliser avant launch).
- **Flutter** iOS + Android.

### Out of Scope (explicitement refusé au MVP)

- Backend custom et sync multi-device
- Comptes utilisateurs / authentification
- Partage social / posts générés depuis fiches (J5, SC8, SC9)
- Ingestion par URL / contenu web scrappé (J6, SC3)
- Interface vocale (SC13)
- Gamification / streak (SC4)
- Re-surfaçage contextuel ambiant (SC12)
- Version web / desktop
- Traduction / multi-langue au-delà du FR/EN
- Catégories / tags / dossiers manuels (décision produit P4)

### Futures considérations (backlog V2)

- **Capture & ingestion** : J6 URL ingestion, SC3 note vocale au moment de la capture
- **Activation avancée** : SC4 streak/gamification, SC6-full "Teste maintenant" avec prompts par type de contenu, SC12 re-surfaçage contextuel, SC13 interface vocale
- **Surface** : SC7 format flashcard swipable
- **Viral / monétisation** : SC8 génération posts LinkedIn, SC9 curations publiques partageables, J5 partage social
- **Plateformes** : sync multi-device (implique backend), version tablette/desktop, plan équipe

---

## Key Stakeholders

- **Clement (Owner / Dev / Designer / Product)** — **Influence : absolue.** Unique décideur, unique développeur, utilisateur primaire au MVP. Pas de cofondateur, pas d'investisseur à ce stade.

Beta-testeurs et early adopters post-launch identifiés comme stakeholders secondaires à recruter (5-10 profils tech) une fois le MVP perso stable.

---

## Constraints and Assumptions

### Contraintes

- **Temps** : 1 mois pour MVP perso, 2 mois pour launch public dans les stores.
- **Ressources** : solo (dev + design + product + QA + marketing).
- **Stack imposée** : Flutter (pas de native iOS/Android pur).
- **Budget IA** : assumé via l'abonnement futur, mais doit rester rentable — OCR local mandatory pour absorber le volume, LLM externe réservé à la digestion.
- **OS** : iOS restreint l'accès continu à Photos en background — l'auto-import Photos Android ne peut pas être répliqué à l'identique sur iOS (accepté, compensé par SC15).
- **Stores** : process de review Apple (1-7j) et Google (< 1j) à intégrer dans le timeline.
- **RGPD / privacy** : stockage local par défaut simplifie le compliance ; les appels LLM externes envoient du texte (pas d'images) → à documenter dans la privacy policy.

### Hypothèses

- Les utilisateurs ont des smartphones iOS/Android récents (< 5 ans) supportant l'OCR on-device.
- Les API IA externes (OpenAI / Anthropic / Google) restent disponibles et leurs tarifs restent stables sur 2026.
- **Le prompt de digestion** peut être calibré pour produire des fiches utiles et engageantes — **à valider en Jalon 0 avant le dev Flutter**.
- Les utilisateurs accepteront 1-2 notifications locales/jour si le contenu porté est contextuel et pertinent.
- Le marché de la veille tech mobile est mature (Readwise, Mymind existent, donc l'appétit utilisateur est prouvé).
- Le porteur est un bon proxy de l'utilisateur type tech-savvy.

---

## Success Criteria

- **Usage perso validé** : consultation ≥ 4×/sem, application ≥ 1/sem, clic-notif ≥ 3/sem (mesuré sur 7 jours consécutifs d'usage réel).
- **Qualité de fiche** : le porteur déclare avoir envie de relire/appliquer ≥ 70 % des fiches générées.
- **Comportement de substitution** : plus aucun retour à Twitter/LinkedIn pour retrouver une information déjà capturée.
- **Launch public** : app disponible sur App Store + Play Store à 2 mois.
- **Feedback beta** : 5-10 beta-testeurs tech recrutés, retour majoritairement positif avant launch officiel.
- **Économie de pipeline** : coût moyen IA par fiche < 0,05 € (condition de viabilité du 9 €/mois).

---

## Timeline and Milestones

### Cible de lancement

- **MVP perso (usage privé)** : ~2026-05-15 (1 mois)
- **Launch public App Store + Play Store** : ~2026-06-15 (2 mois)

### Jalons (ordre, non découpés par semaine)

- **Jalon 0 — Prompt validé** *(préalable non négociable)* : script standalone Python/Node, OCR + LLM, testé sur 15-20 screens réels du porteur. Sortie attendue : fiches dont le porteur déclare "j'ai envie de relire". **Aucune ligne de Flutter tant que ce jalon n'est pas franchi.**
- **Jalon 1 — Pipeline fonctionnel** : capture (import manuel minimum) → OCR local → LLM → fiche stockée et affichée. Focus : bout-en-bout, qualité secondaire.
- **Jalon 2 — Surface** : home éditoriale, recherche sémantique, navigation fiche.
- **Jalon 3 — Activation** : push-teaser (SC14) + push-capture (SC15) + boutons SC6-light. Auto-import Android (SC1) + share sheet (SC5) pour fermer la boucle capture.
- **Jalon 4 — MVP perso complet** : test 7 jours en usage réel par le porteur. Instrumentation des métriques perso. Itération sur le prompt à partir du vécu.
- **Jalon 5 — Polish & stores** : onboarding, privacy policy, pricing/paywall (RevenueCat ou équivalent), bugs, submissions App Store + Play Store.
- **Jalon 6 — Launch public** : review stores passée, app disponible, instrumentation produit/business active.

---

## Risks and Mitigation

- **R1 — Qualité du prompt de digestion.** Si les fiches sont plates, P5 (valeur ajoutée) s'effondre, et par effet domino P1 (push-teaser) aussi.
  - **Probabilité :** Moyenne · **Impact :** Létal
  - **Mitigation :** Jalon 0 obligatoire avant tout dev Flutter. Itérer jusqu'à "j'ai envie de consulter" sur 15-20 screens réels.

- **R2 — Coût IA non maîtrisé.** Si chaque fiche coûte trop en LLM, le 9 €/mois n'est pas rentable.
  - **Probabilité :** Moyenne · **Impact :** Haut
  - **Mitigation :** OCR obligatoirement local, LLM économique (Haiku / GPT-4o-mini) pour digestion, modèle premium réservé à l'action "deep dive" à la demande. Viser coût marginal < 0,05 €/fiche.

- **R3 — Limites OS sur les notifications.** iOS/Android imposent des quotas et des logiques de scheduling (Doze, APN).
  - **Probabilité :** Haute · **Impact :** Moyen
  - **Mitigation :** Notifications locales (pas push serveur), max 2-3/jour combinées, créneaux calmes détectés côté client.

- **R4 — Contrainte iOS sur l'auto-import Photos.** Pas d'accès continu à la galerie en background.
  - **Probabilité :** Haute · **Impact :** *Mitigé*
  - **Mitigation :** Accepté. iOS = import manuel depuis l'app, compensé par SC15 (rappel quotidien). Auto-import reste un avantage Android.

- **R5 — Concurrence.** Mymind / Readwise peuvent ajouter un push IA similaire.
  - **Probabilité :** Moyenne · **Impact :** Moyen
  - **Mitigation :** Vitesse d'exécution (launch à 2 mois), construire un moat sur la qualité du prompt + l'UX mobile-native radicale (home éditoriale, zéro saisie).

- **R6 — Friction d'ajout.** Si la capture reste manuelle et ouvre l'app à chaque fois, l'app meurt à J+14.
  - **Probabilité :** Mitigée · **Impact :** Létal
  - **Mitigation :** SC1 (Android) + SC5 (share sheet) + SC15 (rappel daily) au MVP.

- **R7 — Timing 2 mois tendu.** Qualité prompt + itérations + review stores peuvent déborder.
  - **Probabilité :** Moyenne · **Impact :** Moyen
  - **Mitigation :** Jalon 0 non négociable, découpe serrée, soumettre en TestFlight / Internal Testing dès Jalon 5 pour paralléliser la review.

- **R8 — Pricing 9 €/mois.** Potentiellement élevé pour du consumer mobile.
  - **Probabilité :** Moyenne · **Impact :** Moyen (sur conversion, pas sur lancement)
  - **Mitigation :** A/B tester 5 / 7 / 9 / 12 €/mois post-launch. Ajouter un plan annuel à 59-69 €/an pour réduire le churn et améliorer la LTV.

---

## Next Steps

1. **Jalon 0 — Prototype du prompt de digestion** (hors BMAD, hors Flutter)
   - Script standalone Python ou Node, OCR (Apple Vision ou Tesseract en local, ou ML Kit via CLI) + LLM, sur 15-20 screenshots réels du porteur.
   - Critère de sortie : fiches jugées « j'ai envie de relire ».

2. **Créer le PRD** — `/bmad:prd`
   - Level 2 : features MVP détaillées avec acceptance criteria, user stories, priorités.

3. **Concevoir l'architecture** — `/bmad:architecture`
   - Trancher les 6 questions ouvertes de la section 9 du brainstorming doc (OCR choisi, LLM choisi, embeddings locaux, SC1 iOS, SC2 clustering, timing notifs).

4. **Sprint planning** — `/bmad:sprint-planning` → stories → implémentation.

---

**Ce document a été créé avec la méthode BMAD v6 — Phase 1 (Analyse).**

*Prochaine étape : `/bmad:prd` pour passer à la planification détaillée.*
