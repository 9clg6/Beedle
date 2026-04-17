# Paywall · Plan d'expérimentation (Beedle Pro)

> Source de vérité pour les A/B tests de pricing + copy + gating.
> Mise à jour manuelle quand un test est lancé / gagné / abandonné.

---

## État courant (v1 — launch)

| Variable | Valeur fixée v1 |
| --- | --- |
| Quota free | **15 scans IA / mois** |
| Trial | **7 jours** sur annuel |
| Plan pré-sélectionné | **Annuel** |
| Headline | « Que toutes tes cartes chantent à nouveau » |
| Testimonial | Affiché (1 seule review) |
| Prix annuel | 29,99 € / $29.99 |
| Prix mensuel | 4,99 € / $4.99 |
| Lifetime | 79,99 € · **500 premières activations uniquement** |

---

## Tests priorisés (ordre de déploiement)

### Test 1 — Quota free (plus gros lever conversion)

**Hypothèse** : un quota plus bas force l'upgrade plus tôt, mais un quota
trop bas empêche l'aha moment (recevoir une notif rappel sur une carte
scannée). On cherche le sweet spot.

**Variantes**

| Bucket | Scans / mois | Cible |
| --- | --- | --- |
| A (control) | 15 | 50 % |
| B | 10 | 25 % |
| C | 25 | 25 % |

**Métrique principale** : % users qui démarrent un trial dans les 30 jours
suivant l'install.
**Métrique garde-fou** : retention J30 (si un quota trop bas fait churner).
**N minimum** : 500 users / variante.
**Durée** : jusqu'à 95 % significance, minimum 14 jours.

---

### Test 2 — Trial length

**Variantes** : 3j / 7j (control) / 14j.
**Métrique principale** : trial-to-paid %.
**Métrique secondaire** : revenue per trial-start (catches mix shifts).
**N** : 500 trial starts / variante.

---

### Test 3 — Paywall trigger

**Variantes**

| Bucket | Trigger |
| --- | --- |
| A (control) | Quota scan atteint (12/15 puis 15/15) |
| B | Milestone J+7 + ≥ 10 cartes créées |
| C | Contextuel sur tap feature Pro uniquement |

**Métrique principale** : paywall → purchase %.
**Métrique secondaire** : paywall → dismiss % (si B / C dismissent trop,
on perd le signal commercial).

---

### Test 4 — Plan pré-sélectionné

**Variantes** : Annuel (control) / Mensuel.
**Métrique principale** : ARPU mensuel.
**Attention** : un mensuel plus élu = cash immédiat mais LTV plus bas.
Suivre LTV J90 en vrai signal.

---

### Test 5 — Headline A/B/C

Toutes les variantes respectent CalmSurface (Hanken 600, tracking -0.5%,
`headline.lg`).

#### Variante A · « Bardique » (control on-brand)

```
Que toutes tes cartes
chantent à nouveau
```

Subhead :

> Scan IA sur 100 % de tes trouvailles, et des rappels qui les ramènent
> aux bonnes heures.

#### Variante B · « Utilitaire »

```
Ta veille, indexée.
Et rappelée au bon moment.
```

Subhead :

> Scan IA illimité, recherche par le sens, rappels adaptatifs.
> Tout ce que Notion ne fait pas pour tes screenshots.

#### Variante C · « Possession / anti-oubli »

```
Retrouve tout ce que tu
as failli oublier.
```

Subhead :

> Chaque screenshot devient une carte consultable, taguée, rappelée.
> Fini la galerie cimetière.

**Métrique principale** : tap rate sur le CTA primaire.
**Garde-fou** : taux de retour 3 jours plus tard (évite les headlines
clickbait qui convertissent mal ensuite).

---

### Test 6 — Social proof on/off

**Variantes** : avec testimonial (control) / sans.
**Métrique** : conversion paywall → trial.
**Seuil d'arrêt** : si la review est plus faible que 4.5★ moyenne, à
retirer plutôt qu'à tester.

---

## Copy des contextual paywalls (bottom sheets)

Chaque raison a son wording dédié — cf. `contextual_paywall_sheet.dart`.
À garder en sync si tu modifies.

| Raison | Titre | Body |
| --- | --- | --- |
| `scanQuotaReached` | Tes prochaines cartes / resteraient muettes | Tu as utilisé tes 15 scans IA du mois. Passe Pro pour scanner sans limite — ou reviens le 1er du mois. |
| `semanticSearch` | La recherche par le sens / est Pro | Retrouve une carte par son idée, pas ses mots. Débloque les embeddings et 4 autres sortilèges. |
| `export` | L'export est Pro | Ta veille, portable : Notion, Obsidian, Markdown. Passe Pro pour exporter quand tu veux. |
| `sync` | La sync multi-device / est Pro | iPhone, iPad, Android — tes cartes te suivent partout. Disponible sur le plan Pro. |
| `enrichExisting` | Faire chanter une carte / est Pro | OCR, auto-tags, résumés IA sur toutes tes cartes existantes. Passe Pro pour faire chanter ta bibliothèque entière. |
| `adaptiveReminders` | Les rappels adaptatifs / sont Pro | Le bon rappel, au bon moment, regroupé par thème. Les rappels intelligents arrivent avec Pro. |

---

## Métriques à tracker dès J1

| Métrique | Formule | Cible v1 | Cible mature (M+6) |
| --- | --- | --- | --- |
| Quota-hit rate | Users Free atteignant 15/15 / Users Free actifs | 40 % | 60 % |
| Trial start rate | Trials / paywall views | 15 % | 25-30 % |
| Trial-to-paid | Paid / Trial starts | 40 % | 55-60 % |
| Paywall conversion | Purchases / paywall views | 5 % | 10-15 % |
| ARPU mensuel | Revenue / MAU | ~2 € | 3-4 € |
| Churn mensuel | Cancels / Subs actifs | <15 % | <8 % |

Instrumenter dans Firebase Analytics + RevenueCat dashboard. Les deux
doivent raconter la même histoire.

---

## RevenueCat Experiments — setup

1. Dashboard → **Experiments** → New experiment
2. Audience : `Platform = iOS/Android`, `Country in [FR, US]`
3. Offering control : `default` (annuel pré-sélectionné, trial 7j)
4. Offering variant : créer selon le test (ex: offering `trial_14d` avec
   un package yearly en trial 14 jours)
5. Traffic split : 50/50 ou 33/33/33 si 3 variantes
6. Primary metric : **Trial conversion** (ou revenue si test pricing)
7. Minimum sample : laisser RC calculer

**Règle** : un seul test à la fois par variable (quota OU trial OU copy).
Sinon on ne sait pas ce qui a bougé.

---

## Journal des tests

Remplir ce tableau à chaque test lancé.

| Test # | Début | Fin | Variante gagnante | Uplift | Rolled out ? |
| --- | --- | --- | --- | --- | --- |
| — | — | — | — | — | — |
