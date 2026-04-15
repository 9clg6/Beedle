# Jalon 0 — Prompt Validation

Script standalone **hors Flutter** pour valider la qualité du prompt de digestion
avant de coder l'app. C'est la condition d'entrée obligatoire du Sprint 1 selon
le PRD (R1 — risque létal).

## Prérequis

```bash
# Dépendances Python
pip install openai pillow pytesseract

# Tesseract OCR + langues FR/EN
brew install tesseract tesseract-lang   # macOS
# ou : apt install tesseract-ocr tesseract-ocr-fra tesseract-ocr-eng  (Linux)

# Clé OpenAI
export OPENAI_API_KEY="sk-..."
```

## Usage

1. **Pose 15-20 vrais screenshots** (de ta pellicule) dans `screens/`.
   - Tweets tech, posts LinkedIn, pages de tutos, etc.
   - Mélange FR et EN pour valider le multilingue.
2. **Lance le script** :
   ```bash
   python prompt_validation.py
   ```
3. **Ouvre `results.md`** et, pour chaque fiche, coche subjectivement :
   - `[x] J'ai envie de relire` — si la fiche est engageante, structurée, exploitable
   - `[ ] Non` — si elle est plate, répétitive, vide, ou hallucinée

## Critère de succès (GO / NO GO)

- **≥ 70 %** de fiches "J'ai envie de relire" → **GO** Sprint 1.
- **50-70 %** → tuner le prompt système (ajouter exemples, contraintes, few-shot).
- **< 50 %** → changer de modèle (Claude Haiku 4.5, Gemini Flash) ou revoir le schema.

## Coût

Le script estime le coût/fiche et valide **NFR-004** (< 0,05 €/fiche). Si le
coût explose (résumés trop longs), réduire `max_tokens` ou simplifier le prompt.
