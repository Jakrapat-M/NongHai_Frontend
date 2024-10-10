// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noti_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackingNotiInfo _$TrackingNotiInfoFromJson(Map<String, dynamic> json) =>
    TrackingNotiInfo(
      address: json['address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      petName: json['pet_name'] as String?,
      petImage: json['pet_img'] as String?,
    );

Map<String, dynamic> _$TrackingNotiInfoToJson(TrackingNotiInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'created_at': instance.createdAt.toIso8601String(),
      'pet_name': instance.petName,
      'pet_img': instance.petImage,
    };
