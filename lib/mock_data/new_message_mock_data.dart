import 'package:sociord/models/contact_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class NewMessageMockData {
  static List<ContactItem> getContactsForTab(String tab) {
    switch (tab) {
      case 'Personal':
        return _getPersonalContacts();
      case 'Creator':
        return _getCreatorContacts();
      default:
        return [];
    }
  }

  static List<ContactItem> _getPersonalContacts() {
    return [
      ContactItem(username: 'carlosinmotion', profileImage: kProfilePic),
      ContactItem(username: 'cosmic.route07', profileImage: kProfilePic),
      ContactItem(username: 'noahbright_11', profileImage: kProfilePic),
      ContactItem(username: 'rohanvibe', profileImage: kProfilePic),
      ContactItem(username: 'priya.vision', profileImage: kProfilePic),
      ContactItem(username: 'arthur.orbit', profileImage: kProfilePic),
      ContactItem(username: 'devika.wave_25', profileImage: kProfilePic),
      ContactItem(username: 'grace.legacy', profileImage: kProfilePic),
    ];
  }

  static List<ContactItem> _getCreatorContacts() {
    return [
      ContactItem(username: 'brandy.babe', profileImage: kProfilePic),
      ContactItem(username: 'creative.soul', profileImage: kProfilePic),
      ContactItem(username: 'artistic.mind', profileImage: kProfilePic),
      ContactItem(username: 'designer.pro', profileImage: kProfilePic),
      ContactItem(username: 'content.creator', profileImage: kProfilePic),
      ContactItem(username: 'visual.storyteller', profileImage: kProfilePic),
      ContactItem(username: 'digital.artist', profileImage: kProfilePic),
      ContactItem(username: 'creative.genius', profileImage: kProfilePic),
    ];
  }
}
