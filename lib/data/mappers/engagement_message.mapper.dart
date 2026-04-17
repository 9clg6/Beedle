import 'package:beedle/data/model/local/engagement_message.local.model.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/enum/engagement_message.enum.dart';

extension EngagementMessageLocalModelX on EngagementMessageLocalModel {
  EngagementMessageEntity toEntity() => EngagementMessageEntity(
    uuid: uuid,
    cardUuid: cardUuid,
    content: content,
    type: EngagementMessageType.fromString(type),
    format: EngagementMessageFormat.fromString(format),
    delayDays: delayDays,
    createdAt: createdAt,
    scheduledAt: scheduledAt,
    shownAt: shownAt,
  );
}

extension EngagementMessageEntityToLocalX on EngagementMessageEntity {
  EngagementMessageLocalModel toLocalModel({int? id}) =>
      EngagementMessageLocalModel(
        id: id ?? 0,
        uuid: uuid,
        cardUuid: cardUuid,
        content: content,
        type: type.name,
        format: format.name,
        delayDays: delayDays,
        createdAt: createdAt,
        scheduledAt: scheduledAt,
        shownAt: shownAt,
      );
}
