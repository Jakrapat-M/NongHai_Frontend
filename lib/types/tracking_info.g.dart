// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackingInfo _$TrackingInfoFromJson(Map<String, dynamic> json) => TrackingInfo(
      trackingId: json['id'] as String,
      finderName: json['finder_name'] as String,
      finderChat: json['finder_chat'] as String,
      finderPhone: json['finder_phone'] as String,
      finderImage: json['finder_image'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TrackingInfoToJson(TrackingInfo instance) =>
    <String, dynamic>{
      'id': instance.trackingId,
      'finder_name': instance.finderName,
      'finder_chat': instance.finderChat,
      'finder_phone': instance.finderPhone,
      'finder_image': instance.finderImage,
      'lat': instance.lat,
      'long': instance.long,
      'address': instance.address,
      'created_at': instance.createdAt.toIso8601String(),
    };
