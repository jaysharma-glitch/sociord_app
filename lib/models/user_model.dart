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
  final String? clientUid; // Client-side unique ID based on phone number (for state management before userId exists)
  final LocationModel? location;
  final String? userName;
  final String? gender;
  final String? otherIdentity;
  final String? pronouns;
  final DateTime? birthDate;
  final String? contentType;
  final String? profilePic;
  final String? onboardingStatus; // 'created' → 'profile_basic' → 'personality_data' → 'profile_type_selected' → 'completed'
  final String? creatorIntention; // 'creator' or 'consumer' (intention only; status is user until certified)
  final bool? isCreator; // true only after completing creator certification; use this for creator UI/banner
  final String? ageCohort; // e.g. Boomer, Gen X; optional from API; otherwise computed from birthDate for display

  UserModel(
      {this.userId,
      this.profileType,
      this.firstName,
      this.lastName,
      this.countryCode,
      this.phoneNumber,
      this.clientUid,
      this.location,
      this.userName,
      this.gender,
      this.otherIdentity,
      this.pronouns,
      this.birthDate,
      this.contentType,
      this.profilePic,
      this.onboardingStatus,
      this.creatorIntention,
      this.isCreator,
      this.ageCohort});

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
      String? clientUid,
      LocationModel? location,
      String? userName,
      String? gender,
      String? otherIdentity,
      String? pronouns,
      DateTime? birthDate,
      String? contentType,
      String? profilePic,
      String? onboardingStatus,
      String? creatorIntention,
      bool? isCreator,
      String? ageCohort}) {
    return UserModel(
      userId: userId ?? this.userId,
      profileType: profileType ?? this.profileType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      clientUid: clientUid ?? this.clientUid,
      location: location ?? this.location,
      userName: userName ?? this.userName,
      gender: gender ?? this.gender,
      otherIdentity: otherIdentity ?? this.otherIdentity,
      pronouns: pronouns ?? this.pronouns,
      birthDate: birthDate ?? this.birthDate,
      contentType: contentType ?? this.contentType,
      profilePic: profilePic ?? this.profilePic,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      creatorIntention: creatorIntention ?? this.creatorIntention,
      isCreator: isCreator ?? this.isCreator,
      ageCohort: ageCohort ?? this.ageCohort,
    );
  }

  /// Generate client-side UID from phone number (countryCode + phoneNumber)
  /// This is used for state management before userId is created
  static String generateClientUid(String countryCode, String phoneNumber) {
    return 'client_${countryCode}_$phoneNumber';
  }
}
