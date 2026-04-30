import 'dart:io';
import 'dart:typed_data';

import 'package:beedle/data/clients/worker_client.dart';
import 'package:beedle/domain/repositories/screenshot_storage.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final class ScreenshotStorageRepositoryImpl
    implements ScreenshotStorageRepository {
  ScreenshotStorageRepositoryImpl({required WorkerClient workerClient})
    : _dio = workerClient.dio;

  final Dio _dio;
  final Log _log = Log.named('ScreenshotStorage');

  @override
  Future<String> uploadScreenshot(
    String filePath,
    String screenshotUuid,
  ) async {
    final File file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Screenshot file not found', filePath);
    }

    final Uint8List? compressed =
        await FlutterImageCompress.compressWithFile(
      filePath,
      format: CompressFormat.webp,
      quality: 80,
      minWidth: 1920,
      minHeight: 1920,
    );

    if (compressed == null || compressed.isEmpty) {
      throw const FormatException('Image compression returned empty result');
    }

    _log.info(
      'Compressed screenshot $screenshotUuid: '
      '${file.lengthSync()} → ${compressed.length} bytes',
    );

    final Response<Map<String, dynamic>> response =
        await _dio.put<Map<String, dynamic>>(
      '/screenshots/$screenshotUuid.webp',
      data: Stream<List<int>>.value(compressed),
      options: Options(
        contentType: 'image/webp',
        headers: <String, dynamic>{
          'Content-Length': compressed.length,
        },
      ),
    );

    final String url = response.data!['url'] as String;
    _log.info('Uploaded screenshot $screenshotUuid → $url');
    return url;
  }
}
