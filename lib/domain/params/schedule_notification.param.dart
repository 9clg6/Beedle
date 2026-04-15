import 'package:beedle/domain/enum/notification_type.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_notification.param.freezed.dart';

@Freezed(copyWith: true)
abstract class ScheduleNotificationParam with _$ScheduleNotificationParam {
  const factory ScheduleNotificationParam({
    required NotificationType type,
    required DateTime scheduledAt,
    required String content,
    String? cardUuid,
  }) = _ScheduleNotificationParam;
}
