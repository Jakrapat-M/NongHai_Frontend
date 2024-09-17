// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomData _$ChatRoomDataFromJson(Map<String, dynamic> json) => ChatRoomData(
      roomID: json['id'] as String,
      userID1: json['user_id_1'] as String,
      userID2: json['user_id_2'] as String,
      isUser1Read: json['is_user_1_read'] as bool,
      isUser2Read: json['is_user_2_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChatRoomDataToJson(ChatRoomData instance) =>
    <String, dynamic>{
      'id': instance.roomID,
      'user_id_1': instance.userID1,
      'user_id_2': instance.userID2,
      'is_user_1_read': instance.isUser1Read,
      'is_user_2_read': instance.isUser2Read,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
