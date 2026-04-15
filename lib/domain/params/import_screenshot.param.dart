import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_screenshot.param.freezed.dart';

/// Paramètres pour un import manuel ou share sheet.
@Freezed(copyWith: true)
abstract class ImportScreenshotParam with _$ImportScreenshotParam {
  const factory ImportScreenshotParam({
    required List<String> filePaths,
    @Default('manual') String source, // manual | share | auto_android
  }) = _ImportScreenshotParam;
}
