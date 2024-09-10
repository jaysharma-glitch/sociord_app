// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['userId'] as String?,
      profileType: json['profileType'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      countryCode: json['countryCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      userName: json['userName'] as String?,
      gender: json['gender'] as String?,
      otherIdenty: json['otherIdenty'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      contentType: json['contentType'] as String?,
      profilePic: json['profilePic'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userId': instance.userId,
      'profileType': instance.profileType,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'countryCode': instance.countryCode,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'userName': instance.userName,
      'gender': instance.gender,
      'otherIdenty': instance.otherIdenty,
      'birthDate': instance.birthDate?.toIso8601String(),
      'contentType': instance.contentType,
      'profilePic': instance.profilePic,
    };
