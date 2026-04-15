# Product Requirements Document: Beedle

**Date :** 2026-04-15
**Auteur :** Clement
**Version :** 1.0
**Type de projet :** mobile-app (Flutter, iOS + Android)
**Niveau BMAD :** 2 (5-15 stories, en pratique 16 FRs / 12 NFRs / 4 epics ici)
**Statut :** Draft (à valider avant architecture)

---

## Document Overview

Ce PRD définit les exigences fonctionnelles et non-fonctionnelles pour **Beedle**, l'application mobile qui transforme les screenshots de contenu tech en fiches structurées par IA et pousse activement l'utilisateur à les consommer. Il sert de source de vérité pour le périmètre à construire et trace les exigences jusqu'à l'implémentation.

**Documents liés :**
- Product Brief : [`docs/product-brief-beedle-2026-04-15.md`](./product-brief-beedle-2026-04-15.md)
- Brainstorming : [`docs/brainstorming-beedle-2026-04-15.md`](./brainstorming-beedle-2026-04-15.md)

**Préalable non couvert par ce PRD :** Jalon 0 — prototype du prompt de digestion, validé hors Flutter sur 15-20 screens réels, avant tout dev applicatif. Ce jalon est une condition d'entrée au développement, pas une exigence produit.

---

## Executive Summary

Beedle est une application mobile Flutter (iOS + Android) qui transforme le chaos de screenshots tech en fiches IA structurées, et pousse activement l'utilisateur à les consommer via des notifications locales contenu-based. Le MVP cible les profils tech (veille IA, développeurs, builders), avec un modèle freemium + trial 7 jours et un abonnement Pro à 9 €/mois (plan annuel à définir). Différenciation radicale vs Notion/Obsidian/Readwise : **push actif**, **zéro saisie manuelle**, **home éditoriale**.

---

## Product Goals

### Business Objectives

- Lancer un MVP public iOS + Android dans les stores d'ici ~2 mois (horizon 2026-06-15).
- Valider un product-market fit personnel en mois 1 : le porteur utilise réellement l'app au quotidien.
- Instrumenter un funnel complet d'onboarding, de capture, de consommation et de conversion payante pour itérer post-launch.
- Maintenir un coût marginal IA par fiche < 0,05 € pour la viabilité de l'abonnement.

### Success Metrics

**Usage perso (MVP, fin mois 1) :**
- Consultation de fiches ≥ 4×/semaine
- Application réelle d'astuces ≥ 1/semaine
- Clic sur push-teaser ≥ 3/semaine

**Produit (post-launch, à instrumenter via PostHog) :**
- Funnel onboarding : complétion ≥ 70 % des 12 écrans
- Activation J+7 : ≥ 60 % des users ayant terminé l'OB ont généré ≥ 3 fiches
- CTR push-teaser : ≥ 15 %
- Taux de recherche avec résultat jugé utile : ≥ 50 %

**Business (post-launch) :**
- Conversion trial → paid : ≥ 25 %
- Churn mensuel < 8 %
- Coût IA moyen par fiche < 0,05 €
- DAU/MAU > 30 %

---

## Functional Requirements

### FR-001: Auto-import des screenshots (Android)

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** Sur Android, l'app surveille le dossier Screenshots et importe automatiquement tout nouveau fichier en tâche de fond, même app fermée. L'utilisateur est notifié qu'une nouvelle fiche est en cours de génération.

**Acceptance Criteria :**
- [ ] Service Android `FileObserver` (ou WorkManager) détecte les nouveaux fichiers dans `/Pictures/Screenshots/` dans les 30 s suivant leur création.
- [ ] L'import se produit même si l'app est en arrière-plan ou fermée (tolérance aux redémarrages OS).
- [ ] L'utilisateur peut désactiver l'auto-import dans les paramètres.
- [ ] Les screenshots antérieurs à l'installation de l'app ne sont pas auto-importés (pas de spam initial).

**Dépendances :** NFR-005 (privacy), permissions `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` (Android 13+).

---

### FR-002: Import manuel depuis la galerie (iOS + Android fallback)

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** L'utilisateur peut ouvrir l'app et importer un ou plusieurs screenshots depuis sa pellicule Photos. Sélection multiple native, prévisualisation avant confirmation.

**Acceptance Criteria :**
- [ ] Bouton d'import accessible en 1 tap depuis la home.
- [ ] Picker natif OS (PHPickerViewController iOS, Photo Picker Android 13+).
- [ ] Sélection multiple supportée (jusqu'à 20 images simultanées).
- [ ] Prévisualisation vignettes avant génération.
- [ ] Indication de progression pendant la génération des fiches (un screen = une fiche ou, via FR-006, fusion).

**Dépendances :** Permissions `Photos` iOS / `READ_MEDIA_IMAGES` Android.

---

### FR-003: Share sheet iOS et Android

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** L'app est disponible comme cible dans le share sheet système. Depuis n'importe quelle app (Twitter/X, LinkedIn, navigateur, Photos), l'utilisateur peut partager une image ou du texte vers Beedle pour générer une fiche.

**Acceptance Criteria :**
- [ ] Share Extension iOS acceptant `public.image` et `public.text`.
- [ ] Intent filter Android acceptant `image/*` et `text/plain`.
- [ ] Le partage déclenche la génération sans ouvrir l'app (notif de confirmation).
- [ ] Support du partage multi-images en un seul geste.

**Dépendances :** Flutter plugin `receive_sharing_intent` ou équivalent.

---

### FR-004: OCR local (on-device)

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** L'extraction du texte depuis une image se fait entièrement on-device, sans envoi réseau. Support multilingue (au moins FR + EN, idéalement latin étendu).

**Acceptance Criteria :**
- [ ] OCR appliqué automatiquement à chaque image importée.
- [ ] Temps moyen < 3 s pour un screenshot standard (cf. NFR-001).
- [ ] Fallback : si l'OCR extrait < 10 caractères, la fiche est marquée "OCR faible" et l'utilisateur peut la consulter en "image brute + légende générée depuis l'image via vision LLM" (V2).
- [ ] Le texte brut OCR est stocké localement et accessible pour régénération de fiche (éviter de refaire l'OCR).

**Dépendances :** Google ML Kit (Android + iOS via plugin), ou Apple Vision natif iOS, ou Tesseract (fallback). Décision tranchée en phase architecture.

---

### FR-005: Digestion IA et génération de fiche structurée

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** Le texte OCR est envoyé à un LLM externe avec un prompt calibré pour produire une fiche structurée (non un résumé libre).

**Acceptance Criteria :**
- [ ] Structure de fiche normalisée : titre, résumé exécutif (2-3 lignes), sommaire/étapes (liste), code extrait (bloc si présent), niveau (débutant/intermédiaire/avancé), temps d'exécution estimé, tags auto (max 5), langue détectée.
- [ ] La fiche est générée dans la langue du contenu source (FR ou EN).
- [ ] En cas d'échec LLM (timeout, rate limit, erreur API), la fiche est marquée "en attente" et retentée automatiquement (exponential backoff, max 3 essais).
- [ ] L'utilisateur peut régénérer une fiche manuellement depuis le détail (bouton "Régénérer avec plus de contexte" qui utilise un modèle plus puissant — hors MVP coût).
- [ ] Aucune image n'est envoyée au LLM (seul le texte OCR, cf. NFR-005).

**Dépendances :** FR-004 (OCR), choix LLM (à trancher en archi : GPT-4o-mini / Claude Haiku 4.5 / Gemini Flash).

---

### FR-006: Fusion multi-screenshots en une seule fiche

**Priorité :** Must Have
**Epic :** EPIC-02
**Description :** Lorsque l'utilisateur importe plusieurs screenshots appartenant au même contenu (tuto en plusieurs pages, thread Twitter, etc.), Beedle les regroupe automatiquement en une seule fiche cohérente.

**Acceptance Criteria :**
- [ ] Détection par proximité temporelle (screens pris dans une fenêtre de < 5 min) ET similarité OCR (≥ 40 % de tokens communs ou contexte sémantique proche).
- [ ] Ordre des screens préservé (chronologique de prise).
- [ ] L'utilisateur peut manuellement scinder une fiche fusionnée ou fusionner deux fiches existantes depuis le détail.
- [ ] Les screens individuels restent accessibles dans la fiche (miniatures cliquables en bas).

**Dépendances :** FR-004, FR-005.

---

### FR-007: Home éditoriale

**Priorité :** Must Have
**Epic :** EPIC-03
**Description :** L'écran d'accueil ne présente pas une liste chronologique. Il met en avant **une** suggestion du jour (fiche non encore consultée, choisie par algorithme simple — plus ancienne non consultée, pondérée par tags du quiz d'OB), suivie de 2-3 "à revoir" (fiches consultées il y a > 14 jours).

**Acceptance Criteria :**
- [ ] Aucune liste chronologique visible en home.
- [ ] "Suggestion du jour" change quotidiennement et est régénérée à 00:00 locale.
- [ ] Section "À revoir" affiche 2-3 fiches avec vignette + titre + âge.
- [ ] Une CTA secondaire "Parcourir toutes mes fiches" ouvre une vue liste compacte (non mise en avant).
- [ ] Si l'utilisateur a < 3 fiches, la home affiche un état d'onboarding incitant à importer.

**Dépendances :** FR-005.

---

### FR-008: Recherche sémantique

**Priorité :** Must Have
**Epic :** EPIC-03
**Description :** L'utilisateur peut rechercher une fiche par concept flou. La recherche exploite des embeddings vectoriels locaux pour retrouver des fiches par similarité sémantique, pas seulement par mot-clé exact.

**Acceptance Criteria :**
- [ ] Barre de recherche accessible en 1 tap depuis la home.
- [ ] Embeddings calculés à la génération de chaque fiche et stockés localement.
- [ ] Résultats en < 500 ms sur 1000 fiches (cf. NFR-003).
- [ ] Auto-complétion / suggestions au fil de la frappe (top 3 fiches candidates).
- [ ] Tolérance aux fautes et au cross-langue (recherche en FR retrouve contenu EN pertinent).
- [ ] Aucun tag ni dossier manuel — recherche sémantique uniquement (cf. P4).

**Dépendances :** FR-005, choix embeddings (OpenAI text-embedding-3-small, Cohere, ou local via ONNX — à trancher en archi).

---

### FR-009: Vue fiche détail et actions

**Priorité :** Must Have
**Epic :** EPIC-03
**Description :** La vue fiche affiche la structure complète (titre, résumé, étapes, code, métadonnées) et expose les actions de consommation.

**Acceptance Criteria :**
- [ ] Affichage responsive de tous les champs structurés.
- [ ] Bloc code avec bouton "Copier" en 1 tap.
- [ ] Bouton `[Ouvrir la source]` si une URL a été détectée dans l'OCR (ouvre dans navigateur natif).
- [ ] Bouton `[Ouvrir avec ChatGPT/Claude]` : lance l'app ChatGPT/Claude installée (si détectée) avec le contenu de la fiche pré-rempli, sinon fallback web.
- [ ] Bouton `[Marquer comme testé]` : enregistre la date de consultation active pour les métriques de succès.
- [ ] Accès aux screens originaux en vignettes.
- [ ] Action "Régénérer", "Scinder", "Supprimer" via menu contextuel.

**Dépendances :** FR-005, FR-006.

---

### FR-010: Push-teaser (notifications intelligentes contenu-based)

**Priorité :** Must Have
**Epic :** EPIC-04
**Description :** Notification locale générée depuis une fiche existante, au format hook + action en 1 ligne. 0-2 par jour, timing calé sur les habitudes d'usage détectées.

**Acceptance Criteria :**
- [ ] Génération automatique d'un hook court (< 80 caractères) à partir de chaque fiche, au moment de sa création, stocké avec la fiche.
- [ ] Scheduling local via `flutter_local_notifications` (iOS + Android).
- [ ] Max 2 notifs par 24 h, jamais entre 22:00 et 08:00 locales.
- [ ] Priorité donnée aux fiches non consultées depuis > 7 jours, pondérée par les tags du quiz d'OB.
- [ ] Tap sur notif ouvre directement la fiche concernée.
- [ ] L'utilisateur peut désactiver globalement ou ajuster la fréquence (0, 1, 2/jour) dans les paramètres.
- [ ] Tracking PostHog : envoi, affichage, tap, dismiss.

**Dépendances :** FR-005 (fiche disponible), FR-015 (permission notifs accordée), NFR-011 (langues).

---

### FR-011: Push-capture (rappel quotidien d'import)

**Priorité :** Must Have
**Epic :** EPIC-04
**Description :** Notification locale fixe quotidienne à l'heure choisie par l'utilisateur : *« Tu as des contenus à importer aujourd'hui ? »* Sert en particulier la boucle de capture sur iOS (absence d'auto-import).

**Acceptance Criteria :**
- [ ] Horaire configurable (par défaut 20:00 locale).
- [ ] Peut être désactivée.
- [ ] Variation du libellé (3-5 formulations tournantes pour éviter la lassitude).
- [ ] Tap sur notif ouvre l'écran d'import manuel (FR-002).
- [ ] Si l'utilisateur a importé ≥ 1 fiche dans les dernières 6 h avant le push, la notif est **skippée** ce jour-là.
- [ ] Tracking PostHog.

**Dépendances :** FR-002, FR-015.

---

### FR-012: Onboarding 12 écrans

**Priorité :** Must Have
**Epic :** EPIC-01
**Description :** Premier lancement = parcours d'onboarding activation-focused inspiré des apps B2C modernes (Calm, Duolingo, Blinkist). 12 écrans couvrant vision, problème, features, personnalisation, permissions, trial/paywall, première capture guidée, aha moment.

**Acceptance Criteria :**
- [ ] Séquence des 12 écrans : (1) Hero / (2) Problem story / (3) Preview Capture / (4) Preview Digestion / (5) Preview Push / (6) Quiz perso / (7) Permission primer Notifs / (8) Permission primer Photos / (9) Trial offer / (10) Paywall RevenueCat / (11) Première capture guidée / (12) Aha moment.
- [ ] Skip non disponible avant l'écran 6 (quiz).
- [ ] Chaque écran est instrumenté PostHog (`onboarding_step_viewed`, `onboarding_step_completed`, `onboarding_skipped`).
- [ ] Animations / illustrations sur chaque écran (pas de mur de texte).
- [ ] Navigation retour possible.
- [ ] Paywall skippable (soft paywall) : CTA principal « Démarrer l'essai 7 jours », CTA secondaire « Continuer avec le plan gratuit ».
- [ ] L'onboarding n'est pas rejouable ; accessible post-completion via Paramètres → "Revoir l'onboarding".

**Dépendances :** FR-013, FR-014, FR-015, FR-016.

---

### FR-013: Quiz de personnalisation en onboarding

**Priorité :** Must Have
**Epic :** EPIC-01
**Description :** Quiz de 2-3 questions à choix multiple pour adapter le prompt IA et les push-teasers aux intérêts de l'utilisateur.

**Acceptance Criteria :**
- [ ] Q1 : *"Quel type de contenu tu captures le plus ?"* (choix multiples : Tech/IA, Design, Business, Productivité, Créatif, Autre).
- [ ] Q2 : *"À quelle fréquence tu veux être relancé ?"* (0-2 par jour — configure FR-010 directement).
- [ ] Q3 : *"À quelle heure tu veux ton rappel d'import quotidien ?"* (configure FR-011 directement).
- [ ] Les réponses sont stockées localement et injectées dans le prompt de digestion (biais de structuration selon le type).
- [ ] Les réponses sont envoyées à PostHog comme properties user.

**Dépendances :** FR-012.

---

### FR-014: Paywall et souscription via RevenueCat

**Priorité :** Must Have
**Epic :** EPIC-01
**Description :** Gestion des abonnements in-app (trial 7 jours + Pro à 9 €/mois, plan annuel à 59-69 €/an recommandé mais à valider avant submission) via RevenueCat.

**Acceptance Criteria :**
- [ ] Deux produits dans App Store Connect et Google Play Console : `beedle_pro_monthly` (9 €/mois, trial 7j) et `beedle_pro_yearly` (annuel, trial 7j).
- [ ] Intégration RevenueCat pour unification cross-platform.
- [ ] Entitlement `pro` géré localement et synchronisé avec RevenueCat.
- [ ] États plan gratuit vs Pro clairement gérés (limites freemium à définir en architecture : ex. 30 fiches/mois max en gratuit, push-teaser coupé).
- [ ] Écran paywall accessible depuis (a) onboarding, (b) tentative d'usage d'une feature Pro, (c) paramètres.
- [ ] Webhook RevenueCat vers PostHog pour tracking conversion / churn.
- [ ] Restore purchases disponible.

**Dépendances :** RevenueCat SDK Flutter, comptes développeur Apple/Google.

---

### FR-015: Gestion des permissions OS (permission primers)

**Priorité :** Must Have
**Epic :** EPIC-01
**Description :** Avant chaque permission système sensible (notifications, photos), un écran "primer" custom explique pourquoi et la valeur — pour éviter le refus réflexe et maximiser le taux d'acceptation.

**Acceptance Criteria :**
- [ ] Primer notifications (écran OB 7) avant l'alerte iOS/Android.
- [ ] Primer photos (écran OB 8) avant `PHPickerViewController` / Photo Picker.
- [ ] Si l'utilisateur refuse en primer, skip l'alerte système ; l'app reste fonctionnelle mais avec features dégradées (pas de push, import limité).
- [ ] Écran "Autoriser dans les réglages" accessible depuis les paramètres si l'utilisateur a refusé au système puis veut activer.
- [ ] Tracking PostHog : `permission_primer_shown`, `permission_granted`, `permission_denied`.

**Dépendances :** FR-012.

---

### FR-016: Instrumentation analytics PostHog

**Priorité :** Must Have
**Epic :** EPIC-01
**Description :** Tracking complet de l'utilisateur via PostHog pour le funnel onboarding, les métriques d'activation, la consommation et la conversion payante.

**Acceptance Criteria :**
- [ ] SDK PostHog intégré, anonymous distinct_id local, jamais d'email ni d'identifiant personnel envoyé.
- [ ] Events critiques trackés : onboarding (chaque écran), capture (import, génération succès/échec), consommation (fiche ouverte, action tapée, recherche effectuée), notification (envoyée, tapée, skipée), paywall (shown, trial_started, subscribed, churned).
- [ ] User properties depuis quiz (Q1, Q2, Q3).
- [ ] Consent utilisateur demandé explicitement en écran OB (ou en pop-up premier lancement si écran OB séparé retenu), opt-out possible dans paramètres.
- [ ] Feature flags PostHog disponibles (pour A/B test post-launch des écrans d'OB et prix).

**Dépendances :** PostHog SDK Flutter, conformité RGPD (NFR-009).

---

## Non-Functional Requirements

### NFR-001: Performance OCR

**Priorité :** Must Have
**Description :** L'extraction OCR d'un screenshot standard (< 2 MB, résolution écran mobile) doit aboutir en moins de 3 secondes sur un device récent (iPhone 12+ ou Pixel 6+).

**Acceptance Criteria :**
- [ ] P95 temps OCR < 3 s sur device de référence.
- [ ] P99 < 6 s (cas stress : image haute résolution).

**Rationale :** L'utilisateur ne doit pas avoir l'impression d'attendre — la capture doit rester perçue comme instantanée.

---

### NFR-002: Performance LLM

**Priorité :** Must Have
**Description :** La génération de fiche structurée via LLM doit aboutir en moins de 15 secondes après la fin de l'OCR (connexion 4G standard).

**Acceptance Criteria :**
- [ ] P95 temps LLM < 15 s.
- [ ] UI affiche une progression pendant la génération.
- [ ] En cas de dépassement, la génération continue en arrière-plan avec notification de complétion.

**Rationale :** Au-delà de 20 s, l'utilisateur abandonne l'écran. Le push de notif de complétion permet d'accepter des attentes plus longues sans bloquer.

---

### NFR-003: Performance recherche sémantique

**Priorité :** Must Have
**Description :** Recherche sémantique sur 1000 fiches locales doit retourner les 10 premiers résultats en moins de 500 ms.

**Acceptance Criteria :**
- [ ] Benchmark sur dataset synthétique 1000 fiches.
- [ ] P95 < 500 ms, P99 < 1 s.

**Rationale :** Recherche instantanée obligatoire pour tenir la promesse "retrouver sans se souvenir". Au-delà de 1 s, l'utilisateur tape autre chose ou quitte.

---

### NFR-004: Coût IA par fiche

**Priorité :** Must Have
**Description :** Coût moyen en API LLM externe par fiche générée < 0,05 €.

**Acceptance Criteria :**
- [ ] Monitoring du coût par génération (logs internes).
- [ ] Alerte interne si moyenne mensuelle > 0,05 €.
- [ ] Budget plafonné : un user Pro qui génère > 500 fiches/mois est rate-limité gracieusement à 20/jour.

**Rationale :** À 9 €/mois de revenu, si le coût IA dépasse 15-20 % du revenu, la marge est compromise en incluant Apple/Google (30 %) et PostHog.

---

### NFR-005: Privacy et sécurité des données

**Priorité :** Must Have
**Description :** Stockage 100 % local par défaut. Aucune image envoyée à un tiers. Seul le texte extrait par OCR est transmis au LLM, sur appel unique et non persisté côté serveur.

**Acceptance Criteria :**
- [ ] Aucune image n'entre ni ne sort via réseau (vérifiable par test de trafic).
- [ ] Texte envoyé au LLM via HTTPS uniquement, headers sans identifiant utilisateur.
- [ ] Privacy policy explicite sur : OCR local, texte envoyé au LLM, analytics PostHog anonyme.
- [ ] Conformité avec les termes d'usage de l'API LLM choisie (pas de training sur les données user).
- [ ] Fonction "Tout supprimer" dans paramètres = wipe local complet + opt-out analytics.

**Rationale :** Privacy est un argument de vente vs Notion/Readwise (cloud-first). Aussi obligation RGPD.

---

### NFR-006: Compatibilité OS et devices

**Priorité :** Must Have
**Description :** Support iOS 15+ et Android 8+ (API 26+). Optimisé téléphones uniquement (pas de tablette optimisée au MVP).

**Acceptance Criteria :**
- [ ] Tests sur iPhone SE 3 / iPhone 14, Pixel 5 / Pixel 8.
- [ ] Support écran 4.7" à 6.7".
- [ ] Dégradation gracieuse sur tablette (layout téléphone agrandi, pas de features tablette-spécifiques).

**Rationale :** Toucher 95 %+ des devices récents sans maintenir des cas legacy iOS 13-14 ou Android 5-7.

---

### NFR-007: Scalabilité de la base locale

**Priorité :** Must Have
**Description :** L'app doit rester performante jusqu'à 1000 fiches par utilisateur (cap MVP).

**Acceptance Criteria :**
- [ ] Chargement de la home < 1 s avec 1000 fiches.
- [ ] Recherche respecte NFR-003.
- [ ] Au-delà de 1000, l'app affiche un warning et propose archivage/suppression ; ne casse pas.

**Rationale :** 1000 fiches ≈ 1 an d'usage perso intensif (3 fiches/jour). Au-delà, l'UX vieille-de-10-ans de la liste infinie n'est pas le sujet du MVP.

---

### NFR-008: Disponibilité offline

**Priorité :** Should Have
**Description :** L'app doit rester fonctionnelle offline sauf pour la génération IA et la synchronisation RevenueCat.

**Acceptance Criteria :**
- [ ] OCR local, recherche, navigation, push locaux : 100 % offline.
- [ ] Génération IA : si offline, la fiche est mise en file d'attente et générée au retour de la connexion.
- [ ] Indication UI claire si offline (banner non-bloquant).

**Rationale :** Les transports / avion sont des moments naturels de consultation de veille.

---

### NFR-009: Conformité RGPD et App Store / Play Store

**Priorité :** Must Have
**Description :** Respect total RGPD + Apple App Tracking Transparency + Google Data Safety.

**Acceptance Criteria :**
- [ ] Privacy policy publiée avant soumission, accessible dans l'app.
- [ ] Consentement analytics explicite (Opt-in si marché UE).
- [ ] App Store Connect "Privacy Nutrition Label" renseigné : Data Not Collected (pour les images), Data Used To Track → non, Data Linked To You → non.
- [ ] Google Play Data Safety renseigné.
- [ ] Droit à la suppression : bouton "Supprimer toutes mes données" dans paramètres.
- [ ] Droit à la portabilité : export JSON des fiches (CSV/JSON).

**Rationale :** Sans ça, pas de launch possible dans l'UE. Aussi cohérent avec l'angle privacy du produit.

---

### NFR-010: Accessibilité

**Priorité :** Should Have
**Description :** Support des standards WCAG AA pour contrastes, tailles tactiles et lecteur d'écran (VoiceOver / TalkBack).

**Acceptance Criteria :**
- [ ] Contrastes ≥ 4.5:1 sur textes.
- [ ] Cibles tactiles ≥ 44×44 pt.
- [ ] Labels sémantiques sur tous les boutons/images.
- [ ] Navigation VoiceOver/TalkBack fonctionnelle sur les parcours critiques (onboarding, capture, fiche).

**Rationale :** Standard mobile moderne. Pas un vecteur de vente mais un bloqueur si catastrophique.

---

### NFR-011: Internationalisation FR + EN

**Priorité :** Must Have
**Description :** UI complètement traduite FR + EN. Pipeline IA multilingue. Langue UI suit l'OS, ajustable dans les paramètres.

**Acceptance Criteria :**
- [ ] Toutes les strings dans des fichiers ARB (Flutter intl).
- [ ] OCR supporte FR + EN nativement.
- [ ] LLM prompté pour répondre dans la langue du contenu source détectée.
- [ ] Fallback : si langue UI ≠ langue contenu, la fiche est dans la langue du contenu (pas de traduction automatique au MVP).

**Rationale :** Le porteur est FR mais la majorité du contenu tech est EN. L'UI bilingue ouvre aussi le marché international post-launch.

---

### NFR-012: Maintainabilité et qualité de code

**Priorité :** Should Have
**Description :** Code Flutter structuré, testable, avec couverture de tests unitaires raisonnable.

**Acceptance Criteria :**
- [ ] Architecture en couches (data / domain / presentation) — détail en phase architecture.
- [ ] Linter strict (`flutter_lints` ou VGV lints).
- [ ] Tests unitaires sur la logique métier (génération de fiche, fusion, recherche) ≥ 60 %.
- [ ] Pas de tests UI widget au MVP (coût élevé, ROI faible pour un solo).

**Rationale :** Code soutenable pour un solo qui itérera post-launch.

---

## Epics

### EPIC-01 : Onboarding, Monétisation & Analytics

**Description :** Parcours de premier lancement 12 écrans, quiz de personnalisation, permission primers, paywall RevenueCat, instrumentation PostHog complète. C'est la première impression ET le premier funnel business.

**Functional Requirements :**
- FR-012 (OB 12 écrans)
- FR-013 (Quiz perso)
- FR-014 (Paywall RevenueCat)
- FR-015 (Permission primers)
- FR-016 (Analytics PostHog)

**Story Count Estimate :** 8-10 stories
**Priorité :** Must Have
**Business Value :** Funnel de conversion trial → paid démarre ici. Sans cet epic, pas de revenue et pas de mesure produit.

---

### EPIC-02 : Pipeline Capture & Digestion IA

**Description :** Ingestion des screenshots (auto Android, manuel iOS, share sheet), OCR on-device, appel LLM et génération de fiche structurée, avec fusion automatique multi-screens. Le cœur technique du produit.

**Functional Requirements :**
- FR-001 (Auto-import Android)
- FR-002 (Import manuel)
- FR-003 (Share sheet)
- FR-004 (OCR local)
- FR-005 (Digestion IA)
- FR-006 (Fusion multi-screens)

**Story Count Estimate :** 8-10 stories
**Priorité :** Must Have
**Business Value :** Sans cet epic, rien. C'est la promesse produit tangible.

---

### EPIC-03 : Surface & Recherche

**Description :** Home éditoriale opinionée, vue fiche détail avec actions, recherche sémantique par embeddings. La surface de consommation.

**Functional Requirements :**
- FR-007 (Home éditoriale)
- FR-008 (Recherche sémantique)
- FR-009 (Vue fiche + actions)

**Story Count Estimate :** 5-7 stories
**Priorité :** Must Have
**Business Value :** Rend la bibliothèque exploitable. Implémente le principe P2 (home éditoriale) et P3 (recherche sémantique), différenciateurs vs concurrents.

---

### EPIC-04 : Push Engine

**Description :** Deux boucles de notifications locales distinctes (teaser contenu-based + capture daily fixe), scheduling intelligent, respect des contraintes OS et user.

**Functional Requirements :**
- FR-010 (Push-teaser)
- FR-011 (Push-capture)

**Story Count Estimate :** 3-5 stories
**Priorité :** Must Have
**Business Value :** Le différenciateur absolu de Beedle (P1). Sans cet epic, Beedle = Notion. Avec, Beedle = "la veille qui se rappelle à toi".

---

## User Stories (High-Level)

*Exemples représentatifs par epic. Les user stories détaillées avec estimations seront produites en `/bmad:sprint-planning` (Phase 4).*

**EPIC-01 — Onboarding, Monétisation & Analytics :**
- En tant que nouveau user, je veux comprendre ce que Beedle fait en 2 minutes et sentir la valeur avant de payer, afin de démarrer un trial en confiance.
- En tant que user, je veux répondre à un quiz rapide pour que l'app soit adaptée à ma veille, afin de recevoir des push pertinents dès le premier jour.
- En tant que user, je veux qu'on m'explique pourquoi l'app a besoin de mes notifs et photos avant de me demander l'autorisation système, afin de ne pas refuser par réflexe.

**EPIC-02 — Pipeline Capture & Digestion IA :**
- En tant qu'utilisateur Android, je veux que mes screenshots soient importés automatiquement sans ouvrir Beedle, afin de capturer sans friction.
- En tant qu'utilisateur iOS, je veux partager un tweet depuis l'app Twitter vers Beedle via le share sheet, afin de capturer sans changer de geste.
- En tant que user, je veux qu'un tuto de 10 screens devienne 1 seule fiche structurée, afin de ne pas avoir à faire le tri moi-même.

**EPIC-03 — Surface & Recherche :**
- En tant que user, je veux que la home me propose une fiche à revoir aujourd'hui, afin de ne pas avoir à choisir quoi consulter.
- En tant que user, je veux retrouver "le truc sur les hooks Claude Code" sans me souvenir du nom exact, afin d'accéder à l'info quand j'en ai besoin.
- En tant que user, je veux ouvrir directement dans Claude une fiche contenant un prompt, afin d'appliquer immédiatement sans copier-coller.

**EPIC-04 — Push Engine :**
- En tant que user, je veux recevoir 1-2 notifs par jour avec un contenu qui me donne envie de cliquer, afin de consommer ma veille sans effort.
- En tant qu'utilisateur iOS (sans auto-import), je veux un rappel quotidien pour importer mes screens, afin de ne pas oublier ma veille capturée.

---

## User Personas

### Persona 1 — "Builder Tech" (primaire)

- **Profil :** Dev / PM / builder 28-38 ans, utilise Claude/ChatGPT/Cursor au quotidien.
- **Comportement :** Capture 5-15 screens/jour sur Twitter et LinkedIn. Frustration avec Notion "trop lourd pour du mobile".
- **Motivation :** Transformer sa veille passive en compétences actives.
- **Proxy :** Le porteur du projet lui-même.

### Persona 2 — "Créatif curieux" (secondaire)

- **Profil :** Designer / rédacteur / vidéaste 25-40 ans.
- **Comportement :** Capture références visuelles, posts inspirants, tutos. Utilise Figma et outils IA créatifs.
- **Motivation :** Constituer une bibliothèque de références activable.

### Persona 3 — "Étudiant tech" (secondaire)

- **Profil :** Étudiant en école d'ingé / bootcamp, 20-25 ans.
- **Comportement :** Capture tutos et astuces de personnes seniors suivies sur les réseaux.
- **Motivation :** Apprendre en continu, transformer la veille en pratique.

---

## User Flows

### Flow 1 — Capture auto → consommation poussée (persona Android)

1. L'utilisateur voit un tweet sur Claude Code, fait un screenshot (geste habituel).
2. Beedle détecte le nouveau fichier, OCR local, appel LLM, génération de fiche (< 20 s en tâche de fond).
3. 4 heures plus tard, push-teaser : *"Automatise tes hooks Claude Code en 2 min"*.
4. Tap sur la notif → ouverture directe de la fiche.
5. L'utilisateur clique `[Ouvrir avec Claude]` → Claude s'ouvre avec le prompt de la fiche déjà collé.
6. Action réalisée → retour Beedle → `[Marquer comme testé]`.

### Flow 2 — Capture manuelle iOS via share sheet

1. L'utilisateur lit un post LinkedIn, tape l'icône de partage natif LinkedIn.
2. Sélectionne Beedle dans le share sheet iOS.
3. Confirmation discrète "Fiche en cours de génération".
4. Notif système 15 s plus tard : "Ta fiche est prête".
5. Ouverture de l'app directement sur la fiche en home éditoriale.

### Flow 3 — Retrouver une info par recherche sémantique

1. L'utilisateur a besoin de retrouver une astuce vue "il y a quelques semaines" sur le prompt caching Anthropic.
2. Ouvre Beedle, barre de recherche.
3. Tape "cache anthropic prompt" (approximatif).
4. Top 3 suggestions affichées en temps réel via embeddings.
5. La bonne fiche est la 1ʳᵉ → tap → lecture → `[Copier le code]`.

---

## Dependencies

### Internal Dependencies

- **Préalable Jalon 0** : prompt de digestion validé sur 15-20 screens réels hors Flutter.
- **Packages Flutter** : `receive_sharing_intent`, `flutter_local_notifications`, `google_mlkit_text_recognition` (ou alternative), SDK RevenueCat, SDK PostHog, package embeddings/ANN (à trancher en archi : `sqlite3` + extension `vec0`, ou `isar` avec embeddings externes).
- **Assets** : illustrations et animations pour les 12 écrans d'onboarding (Lottie ou Rive).

### External Dependencies

- **API LLM** : OpenAI (`gpt-4o-mini`) ou Anthropic (`claude-haiku-4-5`) ou Google (`gemini-flash`). Choix tranché en architecture après benchmark sur 15-20 screens.
- **API Embeddings** : `text-embedding-3-small` OpenAI ou équivalent, OU modèle on-device ONNX (ex. `all-MiniLM-L6-v2`). À trancher.
- **RevenueCat** : backend paywall cross-platform.
- **PostHog** : analytics produit.
- **Apple App Store Connect** : compte développeur Apple ($99/an).
- **Google Play Console** : compte développeur Google ($25 one-time).

---

## Assumptions

- Les utilisateurs ont un smartphone iOS ≥ 15 ou Android ≥ 8 (API 26+).
- Les API LLM externes restent disponibles et leurs tarifs ne changent pas drastiquement pendant la phase MVP.
- Le prompt de digestion peut être calibré pour produire des fiches qualité "j'ai envie de consulter" — **à valider en Jalon 0**.
- Les utilisateurs acceptent 1-2 notifs/jour si le contenu est contextuel et pertinent.
- Le marché tech/veille mobile est mature et prêt à payer (validation indirecte via Readwise, Mymind).
- Le porteur est un proxy valide de l'utilisateur type tech-savvy.
- La fusion multi-screens par heuristique simple (temps + similarité OCR) produit des résultats acceptables pour le MVP. Sinon, fallback LLM-based en V2.

---

## Out of Scope

Explicitement exclu du MVP :

- Backend custom et synchronisation multi-device.
- Comptes utilisateurs / authentification email/social.
- Partage social, génération de posts LinkedIn / threads.
- Ingestion de contenu par URL (scraping web).
- Interface vocale (entrée ou sortie).
- Gamification (streaks, badges).
- Re-surfaçage contextuel ambiant (détection d'activité OS).
- Format flashcard swipable.
- Tags, dossiers, catégories manuelles (décision produit P4).
- Curations publiques partageables.
- Version web / desktop.
- Plan équipe / espace partagé.
- Langues autres que FR + EN.
- Modèle "deep dive" premium par fiche à la demande (V2).

---

## Open Questions

À résoudre en **phase Architecture** :

- **Q1 — Choix OCR :** Google ML Kit (Flutter plugin, multi-OS) vs Apple Vision (natif iOS, qualité++) vs Tesseract (offline pur, qualité--). Trade-off : qualité vs simplicité Flutter.
- **Q2 — Choix LLM :** GPT-4o-mini vs Claude Haiku 4.5 vs Gemini Flash. Benchmark obligatoire en Jalon 0 sur 15-20 screens réels.
- **Q3 — Embeddings :** API externe (text-embedding-3-small, ~$0.02/1M tokens, qualité++) vs on-device (ONNX all-MiniLM, qualité--, gratuit). Lié au coût total par fiche.
- **Q4 — Stockage local :** sqlite + sqlite-vec (complexe mais puissant) vs Isar (simple mais sans vector native) vs ObjectBox (vector-native récent). Contraintes sur recherche sémantique.
- **Q5 — Clustering fusion multi-screens (FR-006) :** heuristique temps + Jaccard sur tokens OCR vs LLM call dédié. Impact coût.
- **Q6 — SC1 iOS :** accepter la limitation (import manuel + SC15), OU explorer un Shortcut auto configurable par l'user (user onboarding à produire).
- **Q7 — Timing intelligent des push-teasers (FR-010) :** heuristique simple (heures fixes + exclusion 22h-8h) vs learning sur patterns d'ouverture de l'app. MVP = heuristique simple.
- **Q8 — Freemium cap :** quelle limite exacte en plan gratuit ? 30 fiches/mois, push-teaser coupé, recherche sémantique limitée à X résultats ? À trancher avec product (ou A/B test post-launch).

À résoudre **avant submission stores** :

- Q9 — Plan annuel : prix exact (59, 69, 79 €/an ?).
- Q10 — Privacy policy texte définitif (conforme pipeline LLM externe).
- Q11 — Assets visuels onboarding (sous-traité ou fait maison ?).

---

## Approval & Sign-off

### Stakeholders

- **Clement (Owner / Dev / Designer / Product)** — Influence absolue, seul décideur.

### Approval Status

- [x] Product Owner (Clement — en cours de review de ce doc)
- [x] Engineering Lead (Clement)
- [x] Design Lead (Clement)
- [x] QA Lead (Clement)

---

## Revision History

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.0 | 2026-04-15 | Clement | PRD initial. Dérivé du product-brief et du brainstorming du même jour. |

---

## Next Steps

### Phase 3 : Architecture

Lancer `/bmad:architecture` pour produire l'architecture système. Elle devra trancher les 8 questions ouvertes techniques (OCR, LLM, embeddings, stockage, clustering, iOS constraint, timing notifs, freemium cap) et définir :
- Stack définitive et découpe en couches
- Modèles de données (fiche, screenshot, session, user preferences, subscription state)
- Pipeline asynchrone capture → OCR → LLM → embeddings → stockage
- Gestion offline et queue de retry
- Observabilité (logs locaux, crash reporting, PostHog events)

### Phase 4 : Sprint Planning & Implementation

Après l'architecture, lancer `/bmad:sprint-planning` pour découper les 4 epics en stories détaillées. Estimation globale : **~24-30 stories** pour les 4 epics, à réaliser en ~4 semaines dev (hors Jalon 0 amont).

---

**Document créé avec BMAD Method v6 — Phase 2 (Planning)**

*Prochaine étape : `/bmad:architecture`.*

---

## Appendix A — Matrice de traçabilité

| Epic ID | Epic Name | Functional Requirements | Story Count Est. |
|---------|-----------|-------------------------|------------------|
| EPIC-01 | Onboarding, Monétisation & Analytics | FR-012, FR-013, FR-014, FR-015, FR-016 | 8-10 |
| EPIC-02 | Pipeline Capture & Digestion IA | FR-001, FR-002, FR-003, FR-004, FR-005, FR-006 | 8-10 |
| EPIC-03 | Surface & Recherche | FR-007, FR-008, FR-009 | 5-7 |
| EPIC-04 | Push Engine | FR-010, FR-011 | 3-5 |
| **Total** | **4 epics** | **16 FRs** | **24-32 stories** |

---

## Appendix B — Priorisation

### Functional Requirements (16)

- **Must Have :** 16 / 16 (100 %)
- **Should Have :** 0
- **Could Have :** 0

*Commentaire : tout est Must Have car le périmètre MVP a déjà été arbitré en brainstorm et brief — les "Should" et "Could" sont dans le backlog V2 (voir Out of Scope).*

### Non-Functional Requirements (12)

- **Must Have :** 10 (NFR-001 à 007, NFR-009, NFR-011)
- **Should Have :** 2 (NFR-008 offline, NFR-010 accessibilité, NFR-012 maintainabilité — ces 3 sont des "Should Have" assumés : dégradables si contrainte temps)
- **Could Have :** 0

*Note : NFR-008, NFR-010, NFR-012 sont techniquement 3 Should Have mais l'une est marquée Must par erreur initiale ; à re-trancher en architecture.*

### Observations de priorisation

Le niveau 100 % "Must Have" sur les FRs est **un drapeau rouge** selon la règle MoSCoW classique. Ici, justifié par :
1. Le brainstorm a déjà servi de filtre MoSCoW.
2. Le MVP a été volontairement taillé pour tenir en 1 mois perso + 2 mois public.
3. Le backlog V2 existe (section Out of Scope) et contient la vraie liste des "Could Have".

Mais **si le timing dérape**, les FRs à déprioriser en premier seraient dans cet ordre :

1. FR-006 (fusion multi-screens) → fallback : 1 screen = 1 fiche.
2. FR-013 (quiz perso) → fallback : prompt générique sans biais user.
3. FR-011 (push-capture daily) → fallback : user fait ses imports manuellement.
4. FR-003 (share sheet) → fallback : import manuel depuis l'app seulement.

Ces 4 FRs représentent le "coussin de décote" si la deadline serre.
