// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_personality_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPersonalityModel _$UserPersonalityModelFromJson(
        Map<String, dynamic> json) =>
    UserPersonalityModel(
      userId: json['userId'] as String,
      soundTrackOption: (json['soundTrackOption'] as List<dynamic>)
          .map((e) => PersonalityTraitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekendOption: (json['weekendOption'] as List<dynamic>)
          .map((e) => PersonalityTraitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      connectOption: (json['connectOption'] as List<dynamic>)
          .map((e) => PersonalityTraitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bingeWatchOption: (json['bingeWatchOption'] as List<dynamic>)
          .map((e) => PersonalityTraitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      petOption: json['petOption'] == null
          ? null
          : PersonalityTraitModel.fromJson(
              json['petOption'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPersonalityModelToJson(
        UserPersonalityModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'soundTrackOption': instance.soundTrackOption,
      'weekendOption': instance.weekendOption,
      'connectOption': instance.connectOption,
      'bingeWatchOption': instance.bingeWatchOption,
      'petOption': instance.petOption,
    };
