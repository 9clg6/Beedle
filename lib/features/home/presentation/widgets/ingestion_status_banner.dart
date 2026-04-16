import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banner pill — s'affiche uniquement s'il y a des jobs pending/processing.
///
/// Montre un spinner discret + le count + un label court :
///   [INGEST] analyse de 2 captures…
///
/// Fade-in/out via AnimatedSwitcher pour éviter les flash.
///
/// @deprecated Remplacé par [UploadProgressCard] qui couvre active/failed/
/// success en une seule card persistante au-dessus du TerminalCard. À
/// supprimer après validation en usage réel.
@Deprecated('Utiliser UploadProgressCard à la place')
class IngestionStatusBanner extends ConsumerWidget {
  const IngestionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> asyncCount = ref.watch(_pendingJobsCountProvider);
    final int count = asyncCount.value ?? 0;

    return AnimatedSwitcher(
      duration: CalmDuration.standard,
      switchInCurve: CalmCurves.standard,
      switchOutCurve: CalmCurves.standard,
      child: count == 0
          ? const SizedBox.shrink(key: ValueKey<String>('empty'))
          : _Banner(
              key: const ValueKey<String>('pending'),
              count: count,
            ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.count, super.key});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s4,
        vertical: CalmSpace.s3,
      ),
      decoration: BoxDecoration(
        color: const Color(0x0AFF6B2E), // 4% ember
        borderRadius: BorderRadius.circular(CalmRadius.pill),
        border: Border.all(color: const Color(0x29FF6B2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.ember,
            ),
          ),
          const SizedBox(width: CalmSpace.s3),
          Text(
            LocaleKeys.home_ingestion_label.tr(),
            style: AppTypography.mono(
              const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.ember,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: CalmSpace.s2),
          Text(
            count == 1
                ? LocaleKeys.home_ingestion_single.tr()
                : LocaleKeys.home_ingestion_multiple.tr(
                    namedArgs: <String, String>{'count': '$count'},
                  ),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral7,
            ),
          ),
        ],
      ),
    );
  }
}

/// Count of jobs in status queued|processing.
final StreamProvider<int> _pendingJobsCountProvider = StreamProvider<int>((
  Ref ref,
) {
  return ref
      .watch(ingestionJobRepositoryProvider)
      .watchPending()
      .map(
        (List<IngestionJobEntity> list) => list
            .where(
              (IngestionJobEntity j) =>
                  j.status == IngestionStatus.queued ||
                  j.status == IngestionStatus.processing,
            )
            .length,
      );
});
