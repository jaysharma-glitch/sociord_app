import 'package:json_annotation/json_annotation.dart';
import 'location_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String? userId;
  final String? profileType;
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? phoneNumber;
  final LocationModel? location;
  final String? userName;
  final String? gender;
  final String? otherIdenty;
  final DateTime? birthDate;
  final String? contentType;
  final String? profilePic;

  UserModel(
      {this.userId,
      this.profileType,
      this.firstName,
      this.lastName,
      this.countryCode,
      this.phoneNumber,
      this.location,
      this.userName,
      this.gender,
      this.otherIdenty,
      this.birthDate,
      this.contentType,
      this.profilePic});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith(
      {String? userId,
      String? profileType,
      String? firstName,
      String? lastName,
      String? countryCode,
      String? phoneNumber,
      LocationModel? location,
      String? userName,
      String? gender,
      String? otherIdenty,
      DateTime? birthDate,
      String? contentType,
      String? profilePic}) {
    return UserModel(
        userId: userId ?? this.userId,
        profileType: profileType ?? this.profileType,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        countryCode: countryCode ?? this.countryCode,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        location: location ?? this.location,
        userName: userName ?? this.userName,
        gender: gender ?? this.gender,
        otherIdenty: otherIdenty ?? this.otherIdenty,
        birthDate: birthDate ?? this.birthDate,
        contentType: contentType ?? this.contentType,
        profilePic: profilePic ?? this.profilePic);
  }
}
