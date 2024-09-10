import 'package:json_annotation/json_annotation.dart';
import 'personality_trait_model.dart';

part 'user_personality_model.g.dart';

@JsonSerializable()
class UserPersonalityModel {
  final String userId;
  final List<PersonalityTraitModel> soundTrackOption;
  final List<PersonalityTraitModel> weekendOption;
  final List<PersonalityTraitModel> connectOption;
  final List<PersonalityTraitModel> bingeWatchOption;
  final PersonalityTraitModel? petOption;

  UserPersonalityModel({
    required this.userId,
    required this.soundTrackOption,
    required this.weekendOption,
    required this.connectOption,
    required this.bingeWatchOption,
    this.petOption,
  });

  factory UserPersonalityModel.fromJson(Map<String, dynamic> json) =>
      _$UserPersonalityModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserPersonalityModelToJson(this);

  UserPersonalityModel copyWith({
    String? userId,
    List<PersonalityTraitModel>? soundTrackOption,
    List<PersonalityTraitModel>? weekendOption,
    List<PersonalityTraitModel>? connectOption,
    List<PersonalityTraitModel>? bingeWatchOption,
    PersonalityTraitModel? petOption,
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
