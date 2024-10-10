import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  @JsonKey(name: 'username')
  String? username;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'surname')
  String? surname;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'phone')
  String? phone;

  @JsonKey(name: 'address')
  String? address;

  @JsonKey(name: 'latitude')
  double? latitude;

  @JsonKey(name: 'longitude')
  double? longitude;

  @JsonKey(name: 'image')
  String? image;

  @JsonKey(name: 'pets')
  List<dynamic>? pets;

  UserData({
    this.id,
    this.createdAt,
     this.updatedAt,
    this.username,
     this.name,
     this.surname,
     this.email,
     this.phone,
     this.address,
    this.latitude,
    this.longitude,
    this.image,
    this.pets,
  });

  // Factory method to create a `User` instance from a JSON map.
  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);

  // Method to convert a `User` instance into a JSON map.
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
