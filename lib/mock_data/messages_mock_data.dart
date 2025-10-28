import 'package:sociord/models/message_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class MessagesMockData {
  static List<MessageItem> getMessagesForTab(String tab) {
    switch (tab) {
      case 'Personal':
        return _getPersonalMessages();
      case 'Creator':
        return _getCreatorMessages();
      default:
        return [];
    }
  }

  static List<MessageItem> _getPersonalMessages() {
    return [
      MessageItem(
        username: 'arthur.orbit',
        lastMessage: 'Arjun! I was just thinking about you yest...',
        timestamp: '2:22 pm | Now',
        profileImage: kProfilePic,
        isOnline: true,
        isUnread: true,
      ),
      MessageItem(
        username: 'leahcannely',
        lastMessage: 'Sent you a quickie from treesandbees',
        timestamp: '12:05 pm | Today',
        profileImage: kProfilePic,
        isOnline: false,
        isUnread: true,
      ),
      MessageItem(
        username: 'sarahhmane',
        lastMessage: 'Hey! How are you doing?',
        timestamp: '1:12 pm | Yesterday',
        profileImage: kProfilePic,
        isOnline: false,
      ),
      MessageItem(
        username: 'norah_siblings',
        lastMessage: 'Thanks for the follow back!',
        timestamp: '12:35 pm | Thursday',
        profileImage: kProfilePic,
        isOnline: false,
      ),
      MessageItem(
        username: 'wonder.girl',
        lastMessage: 'Love your latest post!',
        timestamp: '4:55 pm | Wednesday',
        profileImage: kProfilePic,
        isOnline: false,
      ),
      MessageItem(
        username: 'md.ahmed',
        lastMessage: 'Can you check out my new content?',
        timestamp: '3:22 pm | Wednesday',
        profileImage: kProfilePic,
        isOnline: false,
      ),
      MessageItem(
        username: 'archie.rosta',
        lastMessage: 'Great to connect with you!',
        timestamp: '2:15 pm | 20th Jan, 2024',
        profileImage: kProfilePic,
        isOnline: false,
      ),
    ];
  }

  static List<MessageItem> _getCreatorMessages() {
    return [
      MessageItem(
        username: 'arthur.orbit',
        lastMessage: 'Arjun! I was just thinking about you yest...',
        timestamp: '2:22 pm | Now',
        profileImage: kProfilePic,
        isOnline: true,
        isUnread: true,
        relationshipLabel: 'Subscriber',
      ),
      MessageItem(
        username: 'leahcannely',
        lastMessage: 'Sent you a quickie from treesandbees',
        timestamp: '12:05 pm | Today',
        profileImage: kProfilePic,
        isOnline: false,
        isUnread: true,
        relationshipLabel: 'Follower',
      ),
      MessageItem(
        username: 'sarahhmane',
        lastMessage: 'Hey! How are you doing?',
        timestamp: '1:12 pm | Yesterday',
        profileImage: kProfilePic,
        isOnline: false,
        relationshipLabel: 'Follower',
      ),
      MessageItem(
        username: 'norah_siblings',
        lastMessage: 'Thanks for the follow back!',
        timestamp: '12:35 pm | Thursday',
        profileImage: kProfilePic,
        isOnline: false,
        relationshipLabel: 'Following',
      ),
      MessageItem(
        username: 'wonder.girl',
        lastMessage: 'Love your latest post!',
        timestamp: '4:55 pm | Wednesday',
        profileImage: kProfilePic,
        isOnline: false,
        relationshipLabel: 'Subscribed',
      ),
      MessageItem(
        username: 'md.ahmed',
        lastMessage: 'Can you check out my new content?',
        timestamp: '3:22 pm | Wednesday',
        profileImage: kProfilePic,
        isOnline: false,
        relationshipLabel: 'Subscriber',
      ),
      MessageItem(
        username: 'archie.rosta',
        lastMessage: 'Great to connect with you!',
        timestamp: '2:15 pm | 20th Jan, 2024',
        profileImage: kProfilePic,
        isOnline: false,
        relationshipLabel: 'Subscriber',
      ),
    ];
  }
}
