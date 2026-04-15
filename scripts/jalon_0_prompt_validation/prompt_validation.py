"""
Jalon 0 — Validation du prompt de digestion Beedle.

Objectif (STORY-J00) : avant de coder Flutter, valider qu'on peut générer des
fiches que le porteur a envie de relire, sur 15-20 screens réels.

Usage :
    1. `pip install openai pillow pytesseract` (ou utilise Apple Vision via ocrmac)
    2. Pose 15-20 vrais screenshots dans `screens/`
    3. `export OPENAI_API_KEY="sk-..."`
    4. `python prompt_validation.py`
    5. Ouvre `results.md` et note subjectivement si tu as envie de relire
       ≥ 70 % des fiches.

Si < 50 % → revoir le prompt ou changer de modèle (Haiku 4.5, Gemini Flash).
"""

import os
import json
import sys
from pathlib import Path

try:
    import pytesseract
    from PIL import Image
except ImportError:
    print("ERROR: pip install pillow pytesseract (et brew install tesseract tesseract-lang)")
    sys.exit(1)

try:
    from openai import OpenAI
except ImportError:
    print("ERROR: pip install openai")
    sys.exit(1)

SCREENS_DIR = Path(__file__).parent / "screens"
RESULTS_PATH = Path(__file__).parent / "results.md"

SYSTEM_PROMPT = """You are Beedle's digestion engine. Your job is to transform raw OCR text from screenshots (typically tech tweets, LinkedIn posts, tutorials) into a structured card that a busy professional will actually want to re-read.

Rules:
1. Respond strictly in the structured JSON schema provided — no other text.
2. Write in the SAME language as the source content (detect between fr and en).
3. Title: punchy, under 70 characters, no quotes.
4. Summary: 2-3 sentences executives could read in 10 seconds. Action-oriented.
5. Steps: split the content into 3-7 actionable steps if applicable. Use imperative.
6. Code: extract verbatim ALL code blocks, commands, prompts found. Each as a separate string in the array. Empty array if none.
7. Tags: 3-5 short lowercase tags (ex: "claude", "hooks", "automation").
8. Level: beginner | intermediate | advanced — based on technical depth.
9. Estimated minutes: realistic time to actually APPLY this content (1-120). Null if not applicable.
10. Source URL: extract any URL found in the OCR, otherwise null.
11. Language: "fr" or "en".
12. teaserHook: a single-line notification hook (< 80 chars) that makes the user WANT to re-open the card later — e.g. "Automate your Figma with Claude in 2 min". No emoji. No quotes.
"""

JSON_SCHEMA = {
    "name": "beedle_card",
    "strict": True,
    "schema": {
        "type": "object",
        "additionalProperties": False,
        "required": [
            "title", "summary", "steps", "codeBlocks", "tags",
            "level", "estimatedMinutes", "sourceUrl", "language", "teaserHook",
        ],
        "properties": {
            "title": {"type": "string"},
            "summary": {"type": "string"},
            "steps": {"type": "array", "items": {"type": "string"}},
            "codeBlocks": {"type": "array", "items": {"type": "string"}},
            "tags": {"type": "array", "items": {"type": "string"}},
            "level": {"type": "string", "enum": ["beginner", "intermediate", "advanced"]},
            "estimatedMinutes": {"type": ["integer", "null"]},
            "sourceUrl": {"type": ["string", "null"]},
            "language": {"type": "string", "enum": ["fr", "en"]},
            "teaserHook": {"type": "string"},
        },
    },
}


def ocr(image_path: Path) -> str:
    img = Image.open(image_path)
    # `fra+eng` nécessite `brew install tesseract-lang`.
    return pytesseract.image_to_string(img, lang="fra+eng")


def digest(client: OpenAI, ocr_text: str) -> dict:
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"OCR content to digest:\n\n{ocr_text}"},
        ],
        temperature=0.3,
        max_tokens=1200,
        response_format={
            "type": "json_schema",
            "json_schema": JSON_SCHEMA,
        },
    )
    content = response.choices[0].message.content
    return json.loads(content)


def format_card_md(image_name: str, ocr_text: str, card: dict, usage) -> str:
    tokens_in = usage.prompt_tokens
    tokens_out = usage.completion_tokens
    cost_eur = (tokens_in * 0.15 + tokens_out * 0.60) / 1_000_000 * 0.92  # conversion $ → € approx
    return f"""
## {image_name}

**Cost estimate:** {cost_eur:.5f} € (in: {tokens_in} tokens, out: {tokens_out})

### Teaser hook

> {card['teaserHook']}

### Title

**{card['title']}**

### Summary

{card['summary']}

### Meta

- Level : `{card['level']}`
- Minutes : {card.get('estimatedMinutes') or 'n/a'}
- Lang : `{card['language']}`
- Tags : {', '.join(f'`{t}`' for t in card['tags'])}
- URL : {card.get('sourceUrl') or 'n/a'}

### Steps

{chr(10).join(f'{i + 1}. {s}' for i, s in enumerate(card['steps']))}

### Code blocks

{chr(10).join(f'```{chr(10)}{c}{chr(10)}```' for c in card['codeBlocks']) or '_none_'}

### OCR (raw)

<details>
<summary>Voir le texte OCR brut</summary>

```
{ocr_text[:2000]}
```

</details>

**Verdict :** [ ] J'ai envie de relire / [ ] Non

---
"""


def main() -> None:
    if not SCREENS_DIR.exists():
        SCREENS_DIR.mkdir(parents=True)
        print(f"Pose tes screenshots dans {SCREENS_DIR} puis relance.")
        sys.exit(0)

    images = sorted([p for p in SCREENS_DIR.iterdir() if p.suffix.lower() in {'.png', '.jpg', '.jpeg', '.heic'}])
    if not images:
        print(f"Aucun screenshot trouvé dans {SCREENS_DIR}.")
        sys.exit(0)

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("ERROR: export OPENAI_API_KEY=sk-...")
        sys.exit(1)

    client = OpenAI(api_key=api_key)
    md: list[str] = [f"# Beedle Jalon 0 — Prompt Validation\n\nDate: `{os.popen('date').read().strip()}`\nModel: `gpt-4o-mini`\n\n"]
    total_cost = 0.0

    for img_path in images:
        print(f"→ Processing {img_path.name}...")
        try:
            ocr_text = ocr(img_path)
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": f"OCR content to digest:\n\n{ocr_text}"},
                ],
                temperature=0.3,
                max_tokens=1200,
                response_format={"type": "json_schema", "json_schema": JSON_SCHEMA},
            )
            card = json.loads(response.choices[0].message.content or "{}")
            usage = response.usage
            cost = (usage.prompt_tokens * 0.15 + usage.completion_tokens * 0.60) / 1_000_000 * 0.92
            total_cost += cost
            md.append(format_card_md(img_path.name, ocr_text, card, usage))
        except Exception as e:
            md.append(f"\n## {img_path.name}\n\n❌ **ERROR** : {e}\n\n---\n")
            print(f"  ERROR: {e}")

    md.append(f"\n## Summary\n\n- Total cards : {len(images)}\n- Total cost : **{total_cost:.4f} €**\n- Cost per card : **{(total_cost / max(len(images), 1)):.5f} €**\n- NFR-004 cible : < 0,05 €/fiche — {'✅' if (total_cost / max(len(images), 1)) < 0.05 else '❌'}\n")

    RESULTS_PATH.write_text(''.join(md), encoding='utf-8')
    print(f"\n✓ Results written to {RESULTS_PATH}")
    print("Ouvre results.md et coche les cases [ ] J'ai envie de relire pour chaque fiche.")
    print("Critère de succès : ≥ 70 % cochées 'J'ai envie de relire'.")


if __name__ == "__main__":
    main()
