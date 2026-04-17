import 'dart:convert';

import 'package:beedle/data/clients/worker_client.dart';
import 'package:beedle/domain/entities/digestion_result.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/engagement_message.enum.dart';
import 'package:beedle/domain/params/generate_card.param.dart';
import 'package:beedle/domain/repositories/llm.repository.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:dio/dio.dart';

/// Implémentation LLMRepository via Cloudflare Worker proxy → OpenAI GPT-4o-mini.
///
/// **Rôle du LLM = nettoyeur + formateur, pas résumeur.**
/// [fullContent] doit contenir la quasi-totalité du texte source, propre en
/// markdown. [summary] est un TL;DR court en header. [teaserHook] est tiré
/// du fullContent pour alimenter les push-teasers.
final class LLMRepositoryImpl implements LLMRepository {
  LLMRepositoryImpl({required WorkerClient workerClient})
    : _dio = workerClient.dio;

  final Dio _dio;
  final Log _log = Log.named('LLMRepository');

  @override
  Future<DigestionResultEntity> digest(GenerateCardParam param) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': 'gpt-4o-mini',
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': _systemPrompt(
            param.userCategories,
            outputLanguage: param.preferredLanguage,
          ),
        },
        <String, String>{
          'role': 'user',
          'content': 'Raw OCR to clean up and preserve:\n\n${param.ocrText}',
        },
      ],
      'temperature': 0.2,
      'max_tokens': 2000,
      'response_format': <String, dynamic>{
        'type': 'json_schema',
        'json_schema': _jsonSchema(),
      },
    };

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/v1/chat/completions',
        data: payload,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final List<dynamic> choices = body['choices'] as List<dynamic>;
      if (choices.isEmpty) {
        throw const LLMException('Empty choices array from LLM');
      }
      final Map<String, dynamic> message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>;
      final String rawContent = message['content'] as String;

      final Map<String, dynamic> parsed =
          jsonDecode(rawContent) as Map<String, dynamic>;
      return _parseDigestion(parsed);
    } on DioException catch (e) {
      _log.error('LLM request failed: ${e.message}', e);
      throw LLMException(
        'LLM request failed: ${e.message}',
        cause: e,
        statusCode: e.response?.statusCode,
      );
    } on Exception catch (e) {
      _log.error('LLM unexpected error: $e', e);
      throw LLMException('LLM unexpected error', cause: e);
    }
  }

  String _systemPrompt(
    List<ContentCategory> categories, {
    String outputLanguage = 'auto',
  }) {
    final String focus = categories.isEmpty
        ? 'general'
        : categories.map((ContentCategory c) => c.name).join(', ');
    final String languageDirective = _resolveLanguageDirective(outputLanguage);
    return '''
You are Beedle's content preserver. Your job is NOT to summarize — your job is to CLEAN UP raw OCR text from a phone screenshot and turn it into a readable markdown note, preserving the original meaning, structure, and voice.

$languageDirective

User interests (for prompt personalization, NOT for filtering): $focus.

## CRITICAL — Screenshot chrome artefacts to STRIP

The OCR was run on a phone screenshot. The raw text includes UI chrome that is NOT content. **Remove it completely** from fullContent, summary, title, and teaserHook. Examples of chrome to strip:

- Phone status bar: time ("18:47", "14:32"), battery icons ("67", "0l"), network signs ("4G", "5G", "Wi-Fi"), cellular bars.
- App UI artefacts from X/Twitter/Threads/Instagram/LinkedIn/Reddit/Discord:
  - Headers like "Post", "Thread", "Tweet", "Reply"
  - Author line fragments that are pure UI (verified ticks rendered as characters, follower counts, timestamps like "2h", "Sep 5")
  - Nav tabs ("Home", "Explore", "Notifications", "Messages")
  - Action bar icons rendered as text ("Reply 12", "Retweet 34", "Like 567", "Share", "Bookmark")
  - "Show this thread", "Show more", "Translated from X", "Translate post"
  - Encoded emojis that became gibberish (e.g. "SÀ" → likely a flag emoji → drop)
- Keyboard suggestions, autocomplete bars, share sheets.
- Redundant URL previews when the full URL appears twice.

## HANDLING the author / source attribution

If you detect a social-media post, integrate the author attribution as a markdown blockquote at the top of fullContent, on ONE clean line:

  > **Display Name** · @handle · Platform

Examples:
  > **Sthiven R.** · @Sthiven_R · X
  > **Guillaume Moubeche** · @GuillaumeMbh · LinkedIn

If no handle or platform is detectable, just `> **Display Name**`. If there's no author at all, skip the blockquote entirely. Never invent names.

## Contract — what the "fullContent" field MUST be

- A faithful, verbatim-close reproduction of the **actual content** (post body, article text, code, etc.) — NOT the chrome around it.
- OCR artifacts (broken words, missing spaces, wrong punctuation, swapped chars, letters read as digits) → corrected.
- Markdown formatting applied: `#` / `##` for section headers found in the source, bullet lists where the source has lists, numbered lists where imperative steps exist, ```code fenced blocks``` for ALL code/commands/prompts, blockquotes for quoted content.
- Images/diagrams described in a `> ` blockquote line like "> [Diagram: ...]".
- Typography cleanup (smart quotes, en-dashes, etc.).
- **Do NOT summarize. Do NOT paraphrase. Do NOT drop real content.** Length of fullContent ≈ length of the content portion of the OCR after cleanup and chrome removal.

## Contract — the "summary" field

- 2 sentences MAX, punchy, actionable header. Read in 10 seconds.
- Separate from fullContent — it's a TL;DR for the card header.
- Never mention UI chrome, the platform, or the author in the summary.

## Contract — the "teaserHook" field

- A single line, < 80 characters, engaging.
- Generated FROM THE FULLCONTENT, not from the summary.
- Must reflect a specific, compelling angle of the content (a concrete outcome or "aha" hook), not a generic reminder.
- Examples: "Automate Figma with Claude in 2 min", "Le prompt caching divise par 10 ton coût GPT"

## Other fields

- `title`: punchy, < 70 chars, no quotes, same language as source. Never contains the author name or platform.
- `tags`: 3-5 lowercase short tags (e.g. "claude", "hooks", "automation"). Never a platform name (no "twitter", "x", "linkedin" as a tag).
- `level`: beginner | intermediate | advanced.
- `estimatedMinutes`: realistic minutes to APPLY the content (1-120), null if pure inspiration.
- `sourceUrl`: any URL found in OCR, else null.
- `language`: detected — `"fr"` or `"en"`.

## Field `intent`

Classify the card into ONE of three intents, based on how the user will USE it:

- `apply` — **actionable**. A concrete thing to test/do/try: a prompt to run, a workflow, a tool recipe, a specific method. The user should be able to execute it in ≤ 1 hour.
- `read` — **to understand**. An explanation, a concept, an essay, an opinion piece, a mental model. The user reads and thinks, doesn't act directly.
- `reference` — **documentation**. A snippet, a cheatsheet, a list of tools, a glossary. Kept for lookup, not read linearly.

**When unsure between apply/read → prefer apply if there's any clear action, else read.**
`reference` is rarer — reserve it for lists, cheat-sheets, API docs.

## Field `primaryAction`

**ONLY if `intent == "apply"`**. Otherwise `null`.

A single sentence, ≤ 80 characters, **starting with an imperative verb**, describing the ONE concrete thing the user should do with this card. Think of it as the "Daily Lesson call-to-action".

**Examples (good):**
- "Copy the prompt and test it on Claude Sonnet with a real email."
- "Remplace ton prompt actuel par celui-ci et compare sur 3 requêtes."
- "Active prompt caching sur ton Worker et mesure le coût."

**Forbidden:**
- Generic verbs ("Explore this", "Learn about X") → too vague
- 2+ sentences
- "You should..." / "Tu devrais..." → use the imperative directly

## Field `engagementMessages`

Generate **3 to 6 micro-messages** that Beedle's voice can surface later on the home terminal card and as push notifications. Think of these as short observational nudges signed by the content, NOT by a chatbot.

**Mandatory rules:**

- **Tone**: observational, present tense, never exclamatory, zero emoji. Apple-narrator calm, not Duolingo-mom. Never culpabilisant ("tu n'as pas..." / "you forgot..." are FORBIDDEN).
- **Voice**: tutoyer in French, "you" in English. Name-drop the author/source when detected ("Sthiven's prompt", "D'après Guillaume").
- **Specificity**: each message must reference a concrete angle of THIS card (its topic, author, a key insight). Never generic ("Don't forget your cards").
- **Length by format**: `short` ≤ 40 chars (for push notification banner), `long` ≤ 120 chars (for terminal card).
- **Variety of types**: include at least 1 `reminder`, 1 `invite`, and 1 other type per card.
- **`delayDays` distribution**:
  - 0 → surface same day (fresh capture)
  - 3 → re-engagement reminder
  - 7 → "did you try it" invite
  - 14 → reflection
  - 30 → rediscovery
  Spread your N messages across at least 3 different delayDays values.

**Type semantics:**
- `reminder`: a hint to check back ("Ta card de Sthiven sur Claude Opus attend.")
- `invite`: a call to test or apply ("5 min pour tester le prompt de cette card ?")
- `observation`: a neutral stat or pattern ("3 cards de Sthiven cette semaine.")
- `connection`: link to another card ("Ce que dit Sthiven complète ta card d'hier.")
- `reflection`: open question ("Qu'as-tu gardé de cette card ?")

**Format examples (do not copy, illustrative):**

```json
[
  { "content": "Teste le prompt de Sthiven.", "type": "invite", "format": "short", "delayDays": 0 },
  { "content": "Ta card sur Claude Opus attend — Sthiven y répond à 3 objections clés.", "type": "reminder", "format": "long", "delayDays": 3 },
  { "content": "D'après Sthiven, ce prompt marche mieux à température basse.", "type": "observation", "format": "long", "delayDays": 7 },
  { "content": "Qu'as-tu retenu du framework de Sthiven ?", "type": "reflection", "format": "long", "delayDays": 14 }
]
```

Respond strictly in the provided JSON schema. No extra prose.
''';
  }

  Map<String, dynamic> _jsonSchema() {
    return <String, dynamic>{
      'name': 'beedle_card',
      'strict': true,
      'schema': <String, dynamic>{
        'type': 'object',
        'additionalProperties': false,
        'required': <String>[
          'title',
          'summary',
          'fullContent',
          'tags',
          'level',
          'estimatedMinutes',
          'sourceUrl',
          'language',
          'teaserHook',
          'engagementMessages',
          'intent',
          'primaryAction',
        ],
        'properties': <String, dynamic>{
          'title': <String, dynamic>{'type': 'string'},
          'summary': <String, dynamic>{'type': 'string'},
          'fullContent': <String, dynamic>{'type': 'string'},
          'tags': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'type': 'string'},
          },
          'level': <String, dynamic>{
            'type': 'string',
            'enum': <String>['beginner', 'intermediate', 'advanced'],
          },
          'estimatedMinutes': <String, dynamic>{
            'type': <String>['integer', 'null'],
          },
          'sourceUrl': <String, dynamic>{
            'type': <String>['string', 'null'],
          },
          'language': <String, dynamic>{
            'type': 'string',
            'enum': <String>['fr', 'en'],
          },
          'teaserHook': <String, dynamic>{'type': 'string'},
          'intent': <String, dynamic>{
            'type': 'string',
            'enum': <String>['apply', 'read', 'reference'],
          },
          'primaryAction': <String, dynamic>{
            'type': <String>['string', 'null'],
            'maxLength': 80,
          },
          'engagementMessages': <String, dynamic>{
            'type': 'array',
            'minItems': 3,
            'maxItems': 6,
            'items': <String, dynamic>{
              'type': 'object',
              'additionalProperties': false,
              'required': <String>[
                'content',
                'type',
                'format',
                'delayDays',
              ],
              'properties': <String, dynamic>{
                'content': <String, dynamic>{
                  'type': 'string',
                  'maxLength': 120,
                },
                'type': <String, dynamic>{
                  'type': 'string',
                  'enum': <String>[
                    'reminder',
                    'invite',
                    'observation',
                    'connection',
                    'reflection',
                  ],
                },
                'format': <String, dynamic>{
                  'type': 'string',
                  'enum': <String>['short', 'long'],
                },
                'delayDays': <String, dynamic>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 30,
                },
              },
            },
          },
        },
      },
    };
  }

  DigestionResultEntity _parseDigestion(Map<String, dynamic> json) {
    final List<dynamic> rawMessages =
        (json['engagementMessages'] as List<dynamic>?) ?? <dynamic>[];
    final List<DigestedEngagementMessage> messages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map(_parseEngagementMessage)
        .where(_isEngagementMessageValid)
        .toList(growable: false);

    final CardIntent intent = CardIntent.fromString(json['intent'] as String?);
    final String? rawAction = (json['primaryAction'] as String?)?.trim();
    final String? primaryAction =
        (intent == CardIntent.apply && _isPrimaryActionValid(rawAction))
        ? rawAction
        : null;

    return DigestionResultEntity(
      title: (json['title'] as String).trim(),
      summary: (json['summary'] as String).trim(),
      fullContent: (json['fullContent'] as String).trim(),
      tags: (json['tags'] as List<dynamic>)
          .map((dynamic e) => e.toString().toLowerCase())
          .toList(),
      level: CardLevel.fromString(json['level'] as String?),
      language: (json['language'] as String?) ?? 'en',
      teaserHook: (json['teaserHook'] as String).trim(),
      estimatedMinutes: json['estimatedMinutes'] as int?,
      sourceUrl: json['sourceUrl'] as String?,
      engagementMessages: messages,
      intent: intent,
      primaryAction: primaryAction,
    );
  }

  /// Directive de langue pour le LLM — traduit si besoin.
  ///
  /// - `'auto'` → LLM détecte la langue source et préserve.
  /// - `'fr'` ou `'en'` → force la sortie dans cette langue. Le LLM doit
  ///   TRADUIRE si la source est dans une autre langue, tout en préservant
  ///   le sens et le formatage.
  String _resolveLanguageDirective(String code) {
    switch (code) {
      case 'fr':
        return '''
## OUTPUT LANGUAGE — FORCED

ALL output text (title, summary, fullContent, tags, teaserHook, primaryAction, engagementMessages content) MUST be in **French**. If the source OCR is in another language (English, Spanish, etc.), **translate it faithfully** while preserving meaning, structure, code blocks, and names.

- Preserve code, commands, URLs, and English technical terms that don't have a common French equivalent (e.g. "prompt", "embedding", "workflow" are OK to keep in English).
- Proper nouns (people, products) stay as-is.
- The `language` field must be `"fr"` regardless of source language.
''';
      case 'en':
        return '''
## OUTPUT LANGUAGE — FORCED

ALL output text MUST be in **English**. If the source OCR is in another language, translate it faithfully while preserving meaning, structure, code blocks, and names. Proper nouns stay as-is. The `language` field must be `"en"` regardless of source.
''';
      case 'auto':
      default:
        return '''
## OUTPUT LANGUAGE — AUTO

Output in the **same language as the source OCR** (French source → French output, English source → English output). Set the `language` field accordingly.
''';
    }
  }

  /// primaryAction doit : exister, ≤ 80 chars, start par un verbe (minimal
  /// heuristique — on rejette les débuts avec "You should", "Tu devrais").
  static final RegExp _softVerbPattern = RegExp(
    r'^(you should|tu devrais|maybe|perhaps|peut-être)',
    caseSensitive: false,
  );

  bool _isPrimaryActionValid(String? action) {
    if (action == null || action.isEmpty) return false;
    if (action.length > 80) return false;
    if (_softVerbPattern.hasMatch(action)) return false;
    return true;
  }

  DigestedEngagementMessage _parseEngagementMessage(Map<String, dynamic> json) {
    final String content = (json['content'] as String? ?? '').trim();
    return DigestedEngagementMessage(
      content: content,
      type: EngagementMessageType.fromString(json['type'] as String?),
      format: EngagementMessageFormat.fromString(json['format'] as String?),
      delayDays: (json['delayDays'] as int? ?? 0).clamp(0, 30),
    );
  }

  /// Safety net côté Dart — le LLM peut déraper malgré le prompt.
  /// On rejette les messages culpabilisants ou vides.
  static final RegExp _shamePattern = RegExp(
    r"(tu n'?as pas|you forgot|you haven'?t|you should have|tu aurais d[ûu])",
    caseSensitive: false,
  );

  bool _isEngagementMessageValid(DigestedEngagementMessage m) {
    if (m.content.isEmpty) return false;
    if (m.content.length > 120) return false;
    if (_shamePattern.hasMatch(m.content)) return false;
    return true;
  }
}
