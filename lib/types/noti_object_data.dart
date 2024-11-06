import 'package:json_annotation/json_annotation.dart';

part 'noti_object_data.g.dart'; // This file will be generated

@JsonSerializable()
class NotificationObject {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'pet_id')
  final String petId;

  @JsonKey(name: 'tracking_id')
  final String trackingId;

  @JsonKey(name: 'is_read')
  bool isRead;

  @JsonKey(name: 'image')
  String? image;

  NotificationObject({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.petId,
    required this.trackingId,
    required this.isRead,
    this.image,
  });

  // Factory method to create a NotificationObject from JSON
  factory NotificationObject.fromJson(Map<String, dynamic> json) =>
      _$NotificationObjectFromJson(json);

  // Method to convert a NotificationObject to JSON
  Map<String, dynamic> toJson() => _$NotificationObjectToJson(this);
}
