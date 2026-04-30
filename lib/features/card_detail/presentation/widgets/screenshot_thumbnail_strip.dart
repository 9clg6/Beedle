import 'dart:io';

import 'package:beedle/core/providers/app_config.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/features/card_detail/presentation/widgets/screenshot_full_screen_viewer.dart';
import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Strip horizontal de thumbnails — captures originales liées à une card.
/// Tap → ouvre le viewer full-screen zoomable.
class ScreenshotThumbnailStrip extends ConsumerWidget {
  const ScreenshotThumbnailStrip({required this.screenshots, super.key});

  final List<ScreenshotEntity> screenshots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (screenshots.isEmpty) return const SizedBox.shrink();

    final AppConfig config = ref.watch(appConfigProvider);
    final String? userId =
        ref.watch(workerClientProvider).dio.options.headers['X-User-Id']
            as String?;

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: screenshots.length,
        separatorBuilder: (_, __) => const SizedBox(width: CalmSpace.s3),
        itemBuilder: (BuildContext _, int index) {
          final ScreenshotEntity s = screenshots[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => ScreenshotFullScreenViewer(
                  screenshots: screenshots,
                  initialIndex: index,
                  workerBaseUrl: config.workerBaseUrl,
                  userId: userId,
                ),
              ),
            ),
            child: _Thumbnail(
              screenshot: s,
              workerBaseUrl: config.workerBaseUrl,
              userId: userId,
            ),
          );
        },
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.screenshot,
    required this.workerBaseUrl,
    required this.userId,
  });

  final ScreenshotEntity screenshot;
  final String workerBaseUrl;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CalmRadius.lg),
      child: SizedBox(
        width: 100,
        height: 140,
        child: ColoredBox(
          color: AppColors.neutral2,
          child: _resolveImage(),
        ),
      ),
    );
  }

  Widget _resolveImage() {
    if (screenshot.remoteUrl != null && userId != null) {
      return CachedNetworkImage(
        imageUrl: '$workerBaseUrl${screenshot.remoteUrl}',
        httpHeaders: <String, String>{'X-User-Id': userId!},
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _placeholderIcon(),
      );
    }
    final File f = File(screenshot.filePath);
    if (f.existsSync()) {
      return Image.file(f, fit: BoxFit.cover);
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() => const Center(
    child: Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.neutral5,
      size: 24,
    ),
  );
}
