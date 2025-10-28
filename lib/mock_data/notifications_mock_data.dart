import 'package:sociord/models/notification_model.dart';

class NotificationsMockData {
  static List<NotificationItem> getNotificationsForTab(
    String tab,
    bool isCreatorProfile,
  ) {
    switch (tab) {
      case 'All':
        return _getAllNotifications(isCreatorProfile);
      case 'Creator':
        return _getCreatorNotifications();
      case 'Personal':
        return _getPersonalNotifications();
      default:
        return [];
    }
  }

  static List<NotificationItem> _getAllNotifications(bool isCreatorProfile) {
    final notifications = <NotificationItem>[];

    if (isCreatorProfile) {
      // Creator profile - All tab
      notifications.addAll([
        NotificationItem(
          message: "**brandy.babe** just subscribed to you",
          timestamp: "2 hours ago",
          isUnread: true,
          category: "subscription",
          actionButtonText: "Say Thank You",
          onActionButtonTap: () {
            // TODO: Handle say thank you action
            print('Say Thank You tapped');
          },
        ),
        NotificationItem(
          message:
              "Good news: **ramee.mallik** just added you as a buddy. Drop by their profile to say hello 😎",
          timestamp: "2 hours ago",
          isUnread: true,
          category: "buddy",
        ),
        NotificationItem(
          message:
              "Amazing! 🥳 **350** new followers joined you today. Give them a warm welcome by uploading your next clip",
          timestamp: "5 hours ago",
          isUnread: true,
          category: "followers",
        ),
        NotificationItem(
          message:
              "You have a new message from **devon**: 'Hey, I just checked out your profile and I have...'",
          timestamp: "23 hours ago",
          category: "message",
        ),
        NotificationItem(
          message:
              "Your personal picks are ready. We've handpicked three new videos just for you—Hope you like them",
          timestamp: "24 hours ago",
          category: "recommendation",
        ),
        NotificationItem(
          message:
              "Fabulous Job! You've hit **Top 10** in the Elite Circle—your fans are loving you 🏆",
          timestamp: "1 day ago",
          category: "achievement",
        ),
      ]);
    } else {
      // Personal profile - All tab
      notifications.addAll([
        NotificationItem(
          message:
              "**ramona_official** and **40** others want to be your buddy",
          showArrow: true,
          category: "buddy_request",
        ),
        NotificationItem(
          message:
              "Good news: **ramee.mallik** just added you as a buddy. Drop by their profile to say hello 😎",
          timestamp: "2 hours ago",
          isUnread: true,
          category: "buddy",
        ),
        NotificationItem(
          message:
              "Amazing! 🥳 **zack_inwar** and **10** others loved your post",
          timestamp: "5 hours ago",
          isUnread: true,
          category: "like",
        ),
        NotificationItem(
          message:
              "You have a new message from **devon**: 'Hey, I just checked out your profile and I have...'",
          timestamp: "23 hours ago",
          category: "message",
        ),
        NotificationItem(
          message:
              "Your personal picks are ready. We've handpicked three new videos just for you—Hope you like them",
          timestamp: "24 hours ago",
          category: "recommendation",
        ),
        NotificationItem(
          message: "**rayla_inaaravos** just posted—check out what's new",
          timestamp: "1 day ago",
          category: "post",
        ),
      ]);
    }

    return notifications;
  }

  static List<NotificationItem> _getCreatorNotifications() {
    return [
      NotificationItem(
        message: "**brandy.babe** started following you",
        timestamp: "2 hours ago",
        isUnread: true,
        category: "follow",
        actionButtonText: "View Profile",
        onActionButtonTap: () {
          // TODO: Handle view profile action
          print('View Profile tapped');
        },
      ),
      NotificationItem(
        message:
            "Amazing! 🥳 **350** new followers joined you today. Give them a warm welcome by uploading your next clip",
        timestamp: "5 hours ago",
        isUnread: true,
        category: "followers",
      ),
      NotificationItem(
        message:
            "Fabulous Job! You've hit **Top 10** in the Elite Circle—your fans are loving you 🏆",
        timestamp: "1 day ago",
        category: "achievement",
      ),
    ];
  }

  static List<NotificationItem> _getPersonalNotifications() {
    return [
      NotificationItem(
        message: "**ramona_official** and **40** others want to be your buddy",
        showArrow: true,
        category: "buddy_request",
      ),
      NotificationItem(
        message:
            "Good news: **ramee.mallik** just added you as a buddy. Drop by their profile to say hello 😎",
        timestamp: "2 hours ago",
        isUnread: true,
        category: "buddy",
      ),
      NotificationItem(
        message: "Amazing! 🥳 **zack_inwar** and **10** others loved your post",
        timestamp: "5 hours ago",
        isUnread: true,
        category: "like",
      ),
      NotificationItem(
        message:
            "You have a new message from **devon**: 'Hey, I just checked out your profile and I have...'",
        timestamp: "23 hours ago",
        category: "message",
      ),
      NotificationItem(
        message:
            "Your personal picks are ready. We've handpicked three new videos just for you—Hope you like them",
        timestamp: "24 hours ago",
        category: "recommendation",
      ),
      NotificationItem(
        message: "**rayla_inaaravos** just posted—check out what's new",
        timestamp: "1 day ago",
        category: "post",
      ),
    ];
  }
}
