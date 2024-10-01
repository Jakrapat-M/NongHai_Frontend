import 'package:json_annotation/json_annotation.dart';
part 'tracking_info.g.dart';

@JsonSerializable()
class TrackingInfo {
  @JsonKey(name: 'id')
  String trackingId;

  @JsonKey(name: 'finder_name')
  String finderName;

  @JsonKey(name: 'finder_chat')
  String finderChat;

  @JsonKey(name: 'finder_phone')
  String finderPhone;

  @JsonKey(name: 'finder_image')
  String? finderImage;

  @JsonKey(name: 'lat')
  double? lat;

  @JsonKey(name: 'long')
  double? long;

  @JsonKey(name: 'address')
  String? address;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  TrackingInfo({
    required this.trackingId,
    required this.finderName,
    required this.finderChat,
    required this.finderPhone,
    this.finderImage,
    this.lat,
    this.long,
    this.address,
    required this.createdAt,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackingInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingInfoToJson(this);
}
