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
      petOption: null,
    );
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  void setSoundTrackOption(List<PersonalityTraitModel> soundTrackOption) {
    state = state.copyWith(soundTrackOption: soundTrackOption);
  }

  void setWeekendOption(List<PersonalityTraitModel> weekendOption) {
    state = state.copyWith(weekendOption: weekendOption);
  }

  void setConnectOption(List<PersonalityTraitModel> connectOption) {
    state = state.copyWith(connectOption: connectOption);
  }

  void setBingeWatchOption(List<PersonalityTraitModel> bingeWatchOption) {
    state = state.copyWith(bingeWatchOption: bingeWatchOption);
  }

  void setPetOption(PersonalityTraitModel petOption) {
    state = state.copyWith(petOption: petOption);
  }

  Future<List<dynamic>> getSoundtrackOptions() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getSoundtrackOptions();
    return result;
  }

  Future<List<dynamic>> getWeekendOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getWeekendOption();
    return result;
  }

  Future<List<dynamic>> getConnectOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getConnectOption();
    return result;
  }

  Future<List<dynamic>> getBingeWatchOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getBingeWatchOption();
    return result;
  }

  Future<List<dynamic>> getPetOption() async {
    var userPersonalityService = UserPersonalityService();
    var result = await userPersonalityService.getPetOption();
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
