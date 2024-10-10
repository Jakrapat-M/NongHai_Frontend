// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      username: json['username'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      image: json['image'] as String?,
      pets: json['pets'] as List<dynamic>?,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'username': instance.username,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'image': instance.image,
      'pets': instance.pets,
    };
