import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sociord/services/user_personality_service.dart';
import '../models/personality_trait_model.dart';
import '../models/user_personality_model.dart';

part 'user_personality_provider.g.dart';

@riverpod
class UserPersonalityNotifier extends _$UserPersonalityNotifier {
  @override
  UserPersonalityModel build() {
    return UserPersonalityModel(
      userId: '',
      soundTrackOption: [],
      weekendOption: [],
      connectOption: [],
      bingeWatchOption: [],
      petOption: [],
    );
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  void setSoundTrackOption(List<dynamic> soundTrackOption) {
    state = state.copyWith(soundTrackOption: soundTrackOption);
  }

  void setWeekendOption(List<dynamic> weekendOption) {
    state = state.copyWith(weekendOption: weekendOption);
  }

  void setConnectOption(List<dynamic> connectOption) {
    state = state.copyWith(connectOption: connectOption);
  }

  void setBingeWatchOption(List<dynamic> bingeWatchOption) {
    state = state.copyWith(bingeWatchOption: bingeWatchOption);
  }

  void setPetOption(petOption) {
    state = state.copyWith(petOption: petOption);
  }

  Future<List<dynamic>> getSoundtrackOptions() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getSoundtrackOptions();
    setSoundTrackOption(result);
    return result;
  }

  Future<List<dynamic>> getWeekendOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getWeekendOption();
    setWeekendOption(result);
    return result;
  }

  Future<List<dynamic>> getConnectOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getConnectOption();
    setConnectOption(result);
    return result;
  }

  Future<List<dynamic>> getBingeWatchOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getBingeWatchOption();
    setBingeWatchOption(result);
    return result;
  }

  Future<List<dynamic>> getPetOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getPetOption();
    setPetOption(result);
    return result;
  }

  Future<String?> addUserSoundtrackSelection(userId, data) async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.addUserSoundtrackSelection(
        userId: userId, data: data);
    return result;
  }

  Future<String?> addUserWeekendSelection(userId, data) async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.addUserWeekendSelection(
        userId: userId, data: data);
    return result;
  }

  Future<String?> addUserConnectSelection(userId, data) async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.addUserConnectSelection(
        userId: userId, data: data);
    return result;
  }

  Future<String?> addUserBingeWatchSelection(userId, data) async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.addUserBingeWatchSelection(
        userId: userId, data: data);
    return result;
  }

  Future<String?> addUserPetSelection(userId, data) async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.addUserPetSelection(
        userId: userId, data: data);
    return result;
  }
}
