import 'package:json_annotation/json_annotation.dart';
part 'noti_info.g.dart';

@JsonSerializable()
class TrackingNotiInfo {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @JsonKey(name: 'pet_name')
  String? petName;

  @JsonKey(name: 'pet_img')
  String? petImage;

  TrackingNotiInfo({
    required this.address,
    required this.createdAt,
    this.petName,
    this.petImage,
  });

  factory TrackingNotiInfo.fromJson(Map<String, dynamic> json) => _$TrackingNotiInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingNotiInfoToJson(this);
}
