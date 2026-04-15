import 'dart:convert';

import 'package:beedle/data/clients/worker_client.dart';
import 'package:beedle/domain/entities/digestion_result.entity.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
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
    final payload = <String, dynamic>{
      'model': 'gpt-4o-mini',
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': _systemPrompt(param.userCategories),
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
      final response = await _dio.post<dynamic>(
        '/v1/chat/completions',
        data: payload,
      );

      final body = response.data as Map<String, dynamic>;
      final choices = body['choices'] as List<dynamic>;
      if (choices.isEmpty) {
        throw const LLMException('Empty choices array from LLM');
      }
      final message =
          (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>;
      final rawContent = message['content'] as String;

      final parsed = jsonDecode(rawContent) as Map<String, dynamic>;
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

  String _systemPrompt(List<ContentCategory> categories) {
    final focus = categories.isEmpty
        ? 'general'
        : categories.map((c) => c.name).join(', ');
    return '''
You are Beedle's content preserver. Your job is NOT to summarize — your job is to CLEAN UP raw OCR text from a phone screenshot and turn it into a readable markdown note, preserving the original meaning, structure, and voice.

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
        },
      },
    };
  }

  DigestionResultEntity _parseDigestion(Map<String, dynamic> json) {
    return DigestionResultEntity(
      title: (json['title'] as String).trim(),
      summary: (json['summary'] as String).trim(),
      fullContent: (json['fullContent'] as String).trim(),
      tags: (json['tags'] as List<dynamic>).map((dynamic e) => e.toString().toLowerCase()).toList(),
      level: CardLevel.fromString(json['level'] as String?),
      language: (json['language'] as String?) ?? 'en',
      teaserHook: (json['teaserHook'] as String).trim(),
      estimatedMinutes: json['estimatedMinutes'] as int?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }
}
