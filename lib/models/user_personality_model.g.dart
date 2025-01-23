// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_personality_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPersonalityModel _$UserPersonalityModelFromJson(
        Map<String, dynamic> json) =>
    UserPersonalityModel(
      userId: json['userId'] as String,
      soundTrackOption: json['soundTrackOption'] as List<dynamic>,
      weekendOption: json['weekendOption'] as List<dynamic>,
      connectOption: json['connectOption'] as List<dynamic>,
      bingeWatchOption: json['bingeWatchOption'] as List<dynamic>,
      petOption: json['petOption'] as List<dynamic>,
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
