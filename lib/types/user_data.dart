import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  @JsonKey(name: 'username')
  String username;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'surname')
  String surname;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'latitude')
  double latitude;

  @JsonKey(name: 'longitude')
  double longitude;

  @JsonKey(name: 'image')
  String image;

  UserData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  // Factory method to create a `User` instance from a JSON map.
  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);

  // Method to convert a `User` instance into a JSON map.
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
