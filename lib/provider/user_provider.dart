import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sociord/models/location_model.dart';
import 'package:sociord/models/user_model.dart';
import '../services/user_service.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  UserModel build() {
    return UserModel(
      userId: '',
      profileType: '',
      firstName: '',
      lastName: '',
      countryCode: '91',
      phoneNumber: '',
      clientUid: null, // Will be generated when phone number is set
      location: null,
      userName: null,
      gender: null,
      otherIdentity: null,
      pronouns: null,
      birthDate: null,
      contentType: null,
      profilePic: null,
      onboardingStatus: null,
      creatorIntention: null,
    );
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  void setLocationData(LocationModel location) {
    state = state.copyWith(location: location);
  }

  void setProfileType(String profileType) {
    state = state.copyWith(profileType: profileType);
  }

  void setFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void setLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }

  void setCountryCode(String countryCode) {
    state = state.copyWith(countryCode: countryCode);
    // Update clientUid when country code changes (if phone number exists)
    if (state.phoneNumber != null && state.phoneNumber!.isNotEmpty) {
      final clientUid = UserModel.generateClientUid(countryCode, state.phoneNumber!);
      state = state.copyWith(clientUid: clientUid);
    }
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
    // Generate clientUid when phone number is set (countryCode should already be set)
    if (state.countryCode != null && state.countryCode!.isNotEmpty) {
      final clientUid = UserModel.generateClientUid(state.countryCode!, phoneNumber);
      state = state.copyWith(clientUid: clientUid);
    }
  }

  void setLocation(LocationModel location) {
    state = state.copyWith(location: location);
  }

  void setUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  Future<bool> saveUsername(String userName) async {
    print('=== saveUsername called ===');
    print('userName: "$userName"');
    print('Current userId: "${state.userId}"');

    if (state.userId == null || state.userId!.isEmpty) {
      print('ERROR: userId is empty, cannot reserve username');
      throw Exception('User ID is missing. Cannot reserve username.');
    }

    // Release previous username reservation if changing username
    if (state.userName != null &&
        state.userName!.isNotEmpty &&
        state.userName != userName) {
      print('Releasing previous username reservation: "${state.userName}"');
      try {
        await _releaseUsernameReservation(state.userName!);
      } catch (e) {
        print('Error releasing previous reservation: $e');
        // Continue anyway
      }
    }

    var userService = UserService();

    // Reserve username on backend (temporary reservation with TTL)
    try {
      final success = await userService.reserveUsername(
        userId: state.userId!,
        userName: userName,
      );

      if (success) {
        // Update local state only after successful reservation
        setUserName(userName);
        print('Username reserved successfully on backend');

        // Start heartbeat to extend reservation
        _startUsernameReservationHeartbeat(userName);

        return true;
      } else {
        print('Failed to reserve username on backend');
        throw Exception('Failed to reserve username. It may already be taken.');
      }
    } catch (e) {
      print('ERROR reserving username: $e');
      // DO NOT save locally if reservation fails - username must be reserved first
      // Re-throw all errors so UI can handle them appropriately
      rethrow;
    }
  }

  Timer? _usernameReservationHeartbeat;
  Timer? _activityCheckTimer;
  DateTime? _lastActivityTime;

  void _startUsernameReservationHeartbeat(String userName) {
    // Stop existing heartbeat if any
    _stopUsernameReservationHeartbeat();

    _lastActivityTime = DateTime.now();

    // Check activity every minute and extend reservation if active
    _activityCheckTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) async {
      if (state.userId == null || state.userId!.isEmpty) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final timeSinceLastActivity =
          _lastActivityTime != null
              ? now.difference(_lastActivityTime!)
              : const Duration(days: 1);

      // If user inactive for >15 minutes, release reservation
      if (timeSinceLastActivity.inMinutes > 15) {
        print(
          'User inactive for ${timeSinceLastActivity.inMinutes} minutes - releasing reservation',
        );
        await _releaseUsernameReservation(userName);
        timer.cancel();
        return;
      }

      // If user is active, extend reservation every 5 minutes
      if (timeSinceLastActivity.inMinutes % 5 == 0) {
        print('Heartbeat: Extending username reservation for "$userName"');
        try {
          final userService = UserService();
          await userService.extendUsernameReservation(
            userId: state.userId!,
            userName: userName,
          );
        } catch (e) {
          print('Error extending reservation: $e');
          // Continue heartbeat even on error
        }
      }
    });
  }

  void updateActivity() {
    _lastActivityTime = DateTime.now();
    print('Activity updated: $_lastActivityTime');
  }

  void _stopUsernameReservationHeartbeat() {
    _usernameReservationHeartbeat?.cancel();
    _usernameReservationHeartbeat = null;
    _activityCheckTimer?.cancel();
    _activityCheckTimer = null;
    _lastActivityTime = null;
  }

  Future<void> _releaseUsernameReservation(String userName) async {
    if (state.userId == null || state.userId!.isEmpty) {
      return;
    }

    _stopUsernameReservationHeartbeat();

    try {
      final userService = UserService();
      await userService.releaseUsernameReservation(
        userId: state.userId!,
        userName: userName,
      );
      print('Username reservation released: "$userName"');
    } catch (e) {
      print('Error releasing reservation: $e');
    }
  }

  // Call this when user changes username
  Future<void> changeUsername(String newUserName) async {
    if (state.userName != null && state.userName!.isNotEmpty) {
      await _releaseUsernameReservation(state.userName!);
    }
    await saveUsername(newUserName);
  }

  // Call this when onboarding is completed (reservation converts to permanent)
  void completeOnboardingWithUsername() {
    _stopUsernameReservationHeartbeat();
    // Reservation will be converted to permanent by backend
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setOtherIdentity(String? otherIdentity) {
    state = state.copyWith(otherIdentity: otherIdentity);
  }

  void setPronouns(String? pronouns) {
    state = state.copyWith(pronouns: pronouns);
  }

  void setBirthDate(DateTime birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }

  void setContentType(String contentType) {
    state = state.copyWith(contentType: contentType);
  }

  void setprofilePic(String image) {
    state = state.copyWith(profilePic: image);
  }

  Future<UserModel?> getUser() async {
    try {
      var userService = UserService();
      print('userId in get userapi ${state.userId}');
      var result = await userService.getUser(userId: state.userId);
      if (result != null) {
      // Merge API result into state; only overwrite when API returns a non-empty value
      String? pick(String? api, String? current) =>
          (api != null && api.isNotEmpty) ? api : current;
      state = state.copyWith(
        userId: pick(result.userId, state.userId),
        profileType: pick(result.profileType, state.profileType),
        firstName: pick(result.firstName, state.firstName),
        lastName: pick(result.lastName, state.lastName),
        countryCode: pick(result.countryCode, state.countryCode),
        phoneNumber: pick(result.phoneNumber, state.phoneNumber),
        location: result.location ?? state.location,
        userName: pick(result.userName, state.userName),
        gender: pick(result.gender, state.gender),
        otherIdentity: pick(result.otherIdentity, state.otherIdentity),
        pronouns: pick(result.pronouns, state.pronouns),
        birthDate: result.birthDate ?? state.birthDate,
        contentType: pick(result.contentType, state.contentType),
        profilePic: pick(result.profilePic, state.profilePic),
        onboardingStatus: pick(result.onboardingStatus, state.onboardingStatus),
        creatorIntention: pick(result.creatorIntention, state.creatorIntention),
        isCreator: result.isCreator ?? state.isCreator,
        ageCohort: pick(result.ageCohort, state.ageCohort),
      );
      }
      return result;
    } catch (e) {
      print('UserNotifier.getUser error: $e');
      return null;
    }
  }

  Future<bool> createUser() async {
    try {
      var userService = UserService();
      print(state.countryCode);
      var res = await userService.createUser(
        firstName: state.firstName,
        lastName: state.lastName,
        countryCode: state.countryCode,
        phoneNumber: state.phoneNumber,
      );
      print('in provider createUser result: $res');
      if (res != null && res['userId'] != null) {
        setUserId(res['userId']);
        // Set default onboarding status
        state = state.copyWith(onboardingStatus: 'created');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in provider createUser: $e');
      rethrow; // Re-throw so the UI can catch and display the error
    }
  }

  Future<bool> confirmOtp(otp) async {
    var userService = UserService();
    var res = await userService.confirmOtp(
      countryCode: state.countryCode,
      phoneNumber: state.phoneNumber,
      otp: otp,
    );
    print('${state.userId}');
    print('in provider $res');
    return res;
  }

  Future<bool> resendOtp() async {
    var userService = UserService();
    var res = await userService.resendOtp(
      countryCode: state.countryCode,
      phoneNumber: state.phoneNumber,
    );
    print('in provider $res');
    return res;
  }

  Future<bool?> checkUserName(userName) async {
    print('=== checkUserName called ===');
    print('Input userName: "$userName"');
    print('Current userId: "${state.userId}"');
    var userService = UserService();
    // Pass userId to check if username is reserved by current user
    final userId =
        (state.userId != null && state.userId!.isNotEmpty)
            ? state.userId
            : null;
    var res = await userService.checkUsername(
      userName: userName,
      userId: userId,
    );
    print('Service response: $res (type: ${res.runtimeType})');
    print('Returning: $res');
    print('=======================');
    return res;
  }

  Future<List?> generateUsernameOptions(
    userName,
    userId, {
    bool skipPriority1 = false,
  }) async {
    print('=== generateUsernameOptions called ===');
    print('Input userName: "$userName"');
    print('Input userId: "$userId"');
    print('skipPriority1: $skipPriority1');
    var userService = UserService();
    var res = await userService.generateUsernameOptions(
      userName: userName,
      userId: userId,
      skipPriority1: skipPriority1,
    );
    print('Service response: $res (type: ${res.runtimeType})');
    print('Response length: ${res.length}');
    print('Returning: $res');
    print('===================================');
    return res;
  }

  // Get onboarding status
  Future<Map<String, dynamic>?> getOnboardingStatus() async {
    if (state.userId == null || state.userId!.isEmpty) {
      return null;
    }
    var userService = UserService();
    var res = await userService.getOnboardingStatus(userId: state.userId!);
    if (res != null && res['onboardingStatus'] != null) {
      state = state.copyWith(onboardingStatus: res['onboardingStatus']);
      if (res['userName'] != null) {
        state = state.copyWith(userName: res['userName']);
      }
    }
    return res;
  }

  /// Compute age cohort label from birthDate (Boomer, Gen X, Millennial, Gen Z).
  static String computeAgeCohort(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final hadBirthdayThisYear = (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;
    if (age >= 57) return 'Boomer';
    if (age >= 41) return 'Gen X';
    if (age >= 27) return 'Millennial';
    if (age >= 12) return 'Gen Z';
    return 'Alpha'; // under 12
  }

  // Update profile basics (gender, birthdate, ageCohort) - moves status to 'profile_basic'
  Future<bool> updateProfileBasics() async {
    if (state.userId == null || state.userId!.isEmpty) {
      throw Exception('User ID is missing. Cannot update profile basics.');
    }
    final ageCohort = UserNotifier.computeAgeCohort(state.birthDate);
    var userService = UserService();
    var res = await userService.updateProfileBasics(
      userId: state.userId!,
      gender: state.gender,
      otherIdentity: state.otherIdentity,
      pronouns: state.pronouns,
      birthDate: state.birthDate?.toIso8601String(),
      ageCohort: ageCohort.isNotEmpty ? ageCohort : null,
    );
    if (res != null && res['onboardingStatus'] != null) {
      state = state.copyWith(
        onboardingStatus: res['onboardingStatus'],
        ageCohort: ageCohort.isNotEmpty ? ageCohort : state.ageCohort,
      );
      return true;
    }
    return false;
  }

  // Update profile type (creator/consumer) - moves status to 'profile_type_selected'
  Future<bool> updateProfileType(String creatorIntention) async {
    if (state.userId == null || state.userId!.isEmpty) {
      throw Exception('User ID is missing. Cannot update profile type.');
    }
    var userService = UserService();
    var res = await userService.updateProfileType(
      userId: state.userId!,
      creatorIntention: creatorIntention.toLowerCase(), // 'creator' or 'consumer'
    );
    if (res != null && res['onboardingStatus'] != null) {
      state = state.copyWith(
        onboardingStatus: res['onboardingStatus'],
        creatorIntention: res['creatorIntention'],
        isCreator: res['isCreator'] as bool?,
      );
      return true;
    }
    return false;
  }

  // Set username permanently (called when user confirms username selection)
  Future<bool> setUsernamePermanently(String userName) async {
    if (state.userId == null || state.userId!.isEmpty) {
      throw Exception('User ID is missing. Cannot set username.');
    }
    // Stop heartbeat - reservation will be converted to permanent by backend
    completeOnboardingWithUsername();

    var userService = UserService();
    var res = await userService.setUsername(
      userId: state.userId!,
      userName: userName,
    );
    if (res != null && res['userName'] != null) {
      setUserName(res['userName']);
      return true;
    }
    return false;
  }

  // Complete onboarding - sets status to 'completed' (username must be set separately)
  Future<Map<String, dynamic>?> completeOnboarding() async {
    if (state.userId == null || state.userId!.isEmpty) {
      throw Exception('User ID is missing. Cannot complete onboarding.');
    }
    if (state.userName == null || state.userName!.isEmpty) {
      throw Exception('Username must be set before completing onboarding.');
    }

    var userService = UserService();
    var res = await userService.completeOnboarding(userId: state.userId!);
    if (res != null && res['onboardingStatus'] != null) {
      state = state.copyWith(onboardingStatus: res['onboardingStatus']);
    }
    print('in provider completeOnboarding: $res');
    return res;
  }

  Future<String?> addProfilePic(image) async {
    print('=== addProfilePic called ===');
    print('User ID: ${state.userId}');
    print('Image URL: $image');

    if (state.userId == null || state.userId!.isEmpty) {
      throw Exception('User ID is missing. Cannot update profile picture.');
    }

    var userService = UserService();
    var res = await userService.addProfilePic(
      userId: state.userId!,
      image: image,
    );
    print('in provider $res');
    if (res != null) {
      setprofilePic(image);
    }
    return res;
  }

  Future<String?> getSignedUrl(fileType) async {
    var userService = UserService();
    var res = await userService.getSignedUrl(
      fileType: fileType,
      folder: 'profile-pic',
    );
    print('in provider $res');
    return res;
  }

  Future<void> uploadImage(file, signedUrl) async {
    var userService = UserService();
    var res = await userService.uploadFile(file: file, signedUrl: signedUrl);
    if (res) {
      // After uploading to S3, we need to send the image reference to the backend
      // The signed URL format: https://bucket.s3.region.amazonaws.com/key?params
      // Remove query parameters to get the public URL that the backend expects

      // Remove query parameters to get the public URL
      final publicUrl = signedUrl.split('?')[0];

      print('=== Image Upload Complete ===');
      print('Original signed URL: ${signedUrl.substring(0, 100)}...');
      print('Public URL to save: $publicUrl');
      print('=============================');

      // Send the full public URL to the backend
      // The backend expects a valid HTTP/HTTPS URL format
      await addProfilePic(publicUrl);
    }
  }

  Future<String?> userLogin() async {
    var userService = UserService();
    var result = await userService.userLogin(
      phoneNumber: state.phoneNumber,
      countryCode: state.countryCode,
    );
    if (result != null) {
      setUserId(result);
    }
    print('provider $result');
    return result;
  }

  /// Check if username reservation is still valid (called on app resume)
  /// Returns true if reservation is valid, false if expired (user needs to re-reserve)
  Future<bool> checkReservationValidity() async {
    if (state.userName == null || state.userName!.isEmpty) {
      return true; // No reservation to check
    }

    if (state.userId == null || state.userId!.isEmpty) {
      return false;
    }

    try {
      final userService = UserService();
      final availability = await userService.checkUsername(
        userName: state.userName!,
        userId: state.userId,
      );

      // If username is available, reservation expired - need to re-reserve
      if (availability == true) {
        print(
          'Reservation expired for "${state.userName}" - clearing username',
        );
        // Clear local username so user goes back to username page
        setUserName('');
        // Release any heartbeat
        _stopUsernameReservationHeartbeat();
        return false;
      }

      // Username is not available - could be permanently taken or still reserved
      // If it's permanently taken by another user, we'll find out when user tries to continue
      print(
        'Reservation check: Username "${state.userName}" is not available (may be reserved or taken)',
      );
      return true;
    } catch (e) {
      print('Error checking reservation validity: $e');
      return false;
    }
  }
}
