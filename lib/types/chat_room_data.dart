import 'package:json_annotation/json_annotation.dart';
part 'chat_room_data.g.dart';

@JsonSerializable()
class ChatRoomData {
  @JsonKey(name: 'id')
  String roomID;

  @JsonKey(name: 'user_id_1')
  String userID1;

  @JsonKey(name: 'user_id_2')
  String userID2;

  @JsonKey(name: 'is_user_1_read')
  bool isUser1Read;

  @JsonKey(name: 'is_user_2_read')
  bool isUser2Read;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ChatRoomData({
    required this.roomID,
    required this.userID1,
    required this.userID2,
    required this.isUser1Read,
    required this.isUser2Read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomData.fromJson(Map<String, dynamic> json) => _$ChatRoomDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomDataToJson(this);
}
