import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sociord/models/location_model.dart';
import 'package:sociord/models/user_model.dart';
import 'package:sociord/provider/location_provider.dart';
import '../services/user_service.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserModel build() {
    final locationProvider = ref.watch(locationNotifierProvider);
    return UserModel(
      userId: '',
      profileType: '',
      firstName: '',
      lastName: '',
      countryCode: '91',
      phoneNumber: '',
      location: locationProvider.location,
      userName: null,
      gender: null,
      otherIdenty: null,
      birthDate: null,
      contentType: null,
      profilePic: null,
    );
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
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
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void setLocation(LocationModel location) {
    state = state.copyWith(location: location);
  }

  void setUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setOtherIdenty(String otherIdenty) {
    state = state.copyWith(otherIdenty: otherIdenty);
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
    var userService = UserService();
    var result = await userService.getUser(userId: state.userId);
    if (result != null) {
      // Update the entire state with the returned UserModel
      state = result;
    }
    return result;
  }

  Future<bool> createUser() async {
    var userService = UserService();
    print(state.countryCode);
    var res = await userService.createUser(
        profileType: state.profileType,
        firstName: state.firstName,
        lastName: state.lastName,
        countryCode: state.countryCode,
        phoneNumber: state.phoneNumber);
    print('in provider $res');
    state = state.copyWith(userId: res);
    if (res != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> confirmOtp(otp) async {
    var userService = UserService();
    var res = await userService.confirmOtp(
        countryCode: state.countryCode,
        phoneNumber: state.phoneNumber,
        otp: otp);
    print('in provider $res');
    return res;
  }

  Future<bool> resendOtp() async {
    var userService = UserService();
    var res = await userService.resendOtp(
        countryCode: state.countryCode, phoneNumber: state.phoneNumber);
    print('in provider $res');
    return res;
  }

  Future<bool?> checkUserName(userName) async {
    var userService = UserService();
    var res = await userService.checkUsername(userName: userName);
    print('in provider $res');
    return res;
  }

  Future<List?> generateUsernameOptions(userName, userId) async {
    var userService = UserService();
    var res = await userService.generateUsernameOptions(
        userName: userName, userId: userId);
    print('in provider $res');
    return res;
  }

  Future<Map?> completeOnboarding() async {
    var userService = UserService();
    var res = await userService.completeOnboarding(
        userId: state.userId,
        userName: state.userName,
        gender: state.gender,
        otherIdenty: state.otherIdenty,
        birthDate: state.birthDate!.toIso8601String(),
        contentType: state.contentType);
    print('in provider $res');
    return res;
  }

  Future<String?> addProfilePic(image) async {
    var userService = UserService();
    var res =
        await userService.addProfilePic(userId: state.userId, image: image);
    print('in provider $res');
    if (res != null) {
      setprofilePic(image);
    }
    return res;
  }

  Future<String?> getSignedUrl(fileType) async {
    var userService = UserService();
    var res = await userService.getSignedUrl(
        fileType: fileType, folder: 'profile-pic');
    print('in provider $res');
    return res;
  }

  Future<void> uploadImage(file, signedUrl) async {
    var userService = UserService();
    var res = await userService.uploadFile(file: file, signedUrl: signedUrl);
    if (res) {
      var baseUrl = signedUrl.split('?')[0];
      await addProfilePic(baseUrl);
    }
  }

  Future<String?> userLogin() async {
    var userService = UserService();
    var result = await userService.userLogin(
        phoneNumber: state.phoneNumber, countryCode: state.countryCode);
    if (result != null) {
      setUserId(result);
    }
    print('provider $result');
    return result;
  }
}
