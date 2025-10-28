import 'package:sociord/models/buddy_request_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class BuddyRequestsMockData {
  static List<BuddyRequest> getBuddyRequests() {
    return [
      BuddyRequest(
        id: '1',
        username: 'cosmic.route07',
        message: 'Hi ! The last I saw you was in high school. What\'s up ?',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
      BuddyRequest(
        id: '2',
        username: 'noahbright_11',
        message: 'Your posts caught my eye. Let\'s be friends?',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
      BuddyRequest(
        id: '3',
        username: 'rohanvibe',
        message: 'So glad to stumble upon your profile. Add me, let\'s chat!',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
    ];
  }

  static List<BuddySuggestion> getSuggestions() {
    return [
      BuddySuggestion(
        id: '1',
        username: 'priya.vision',
        demographics: 'Female, Millenial',
        location: 'North Dakota, US',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
      BuddySuggestion(
        id: '2',
        username: 'alex.orbit',
        demographics: 'Trans Man, Millenial',
        location: 'California, US',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
      BuddySuggestion(
        id: '3',
        username: 'devika.wave_25',
        demographics: 'Female, GenZ',
        location: 'Toronto, Canada',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
      BuddySuggestion(
        id: '4',
        username: 'grace.legacy',
        demographics: 'Female, GenZ',
        location: 'Mumbai, India',
        profileImage: kProfilePic, // Using existing profile image constant
      ),
    ];
  }
}
