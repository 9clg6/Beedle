import 'package:beedle/data/model/local/notification_record.local.model.dart';
import 'package:beedle/domain/entities/notification_record.entity.dart';
import 'package:beedle/domain/enum/notification_type.enum.dart';

extension NotificationRecordLocalModelX on NotificationRecordLocalModel {
  NotificationRecordEntity toEntity() => NotificationRecordEntity(
    uuid: uuid,
    type: NotificationType.fromString(type),
    scheduledAt: scheduledAt,
    cardUuid: cardUuid,
    content: content,
    sentAt: sentAt,
    tappedAt: tappedAt,
    dismissedAt: dismissedAt,
  );
}

extension NotificationRecordEntityToLocalX on NotificationRecordEntity {
  NotificationRecordLocalModel toLocalModel({int? id}) =>
      NotificationRecordLocalModel(
        id: id ?? 0,
        uuid: uuid,
        type: type.name,
        scheduledAt: scheduledAt,
        cardUuid: cardUuid,
        content: content,
        sentAt: sentAt,
        tappedAt: tappedAt,
        dismissedAt: dismissedAt,
      );
}
