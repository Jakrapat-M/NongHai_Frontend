// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noti_object_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationObject _$NotificationObjectFromJson(Map<String, dynamic> json) =>
    NotificationObject(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String,
      petId: json['pet_id'] as String,
      trackingId: json['tracking_id'] as String,
      isRead: json['is_read'] as bool,
    );

Map<String, dynamic> _$NotificationObjectToJson(NotificationObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'user_id': instance.userId,
      'pet_id': instance.petId,
      'tracking_id': instance.trackingId,
      'is_read': instance.isRead,
    };
