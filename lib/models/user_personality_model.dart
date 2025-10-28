import 'package:json_annotation/json_annotation.dart';

part 'user_personality_model.g.dart';

@JsonSerializable()
class UserPersonalityModel {
  final String userId;
  final List<dynamic> soundTrackOption;
  final List<dynamic> weekendOption;
  final List<dynamic> connectOption;
  final List<dynamic> bingeWatchOption;
  final List<dynamic> petOption;

  UserPersonalityModel({
    required this.userId,
    required this.soundTrackOption,
    required this.weekendOption,
    required this.connectOption,
    required this.bingeWatchOption,
    required this.petOption,
  });

  factory UserPersonalityModel.fromJson(Map<String, dynamic> json) =>
      _$UserPersonalityModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserPersonalityModelToJson(this);

  UserPersonalityModel copyWith({
    String? userId,
    List<dynamic>? soundTrackOption,
    List<dynamic>? weekendOption,
    List<dynamic>? connectOption,
    List<dynamic>? bingeWatchOption,
    List<dynamic>? petOption,
  }) {
    return UserPersonalityModel(
      userId: userId ?? this.userId,
      soundTrackOption: soundTrackOption ?? this.soundTrackOption,
      weekendOption: weekendOption ?? this.weekendOption,
      connectOption: connectOption ?? this.connectOption,
      bingeWatchOption: bingeWatchOption ?? this.bingeWatchOption,
      petOption: petOption ?? this.petOption,
    );
  }
}
