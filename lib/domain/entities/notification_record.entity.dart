import 'package:beedle/domain/enum/notification_type.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_record.entity.freezed.dart';

/// Entité trace de notification locale — pour audit + cap freemium + analytics.
@freezed
abstract class NotificationRecordEntity with _$NotificationRecordEntity {
  const factory NotificationRecordEntity({
    required String uuid,
    required NotificationType type,
    required DateTime scheduledAt,
    String? cardUuid,
    String? content,
    DateTime? sentAt,
    DateTime? tappedAt,
    DateTime? dismissedAt,
  }) = _NotificationRecordEntity;
}
