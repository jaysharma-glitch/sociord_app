import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/notifications_mock_data.dart';
import 'package:sociord/models/notification_model.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/screens/buddy_requests/buddy_requests_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedTab = 'All';
  bool isCreatorProfile = true; // This should come from user profile data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios, color: kAppBlack, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: kAppBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs =
        isCreatorProfile ? ['All', 'Creator', 'Personal'] : ['All', 'Personal'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            tabs.map((tab) {
              final isSelected = selectedTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = tab;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? kAppPurple : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isSelected ? kAppPurple : kAppLightBlack,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    final notifications = NotificationsMockData.getNotificationsForTab(
      selectedTab,
      isCreatorProfile,
    );

    // Group notifications by category
    final buddyRequests =
        notifications.where((n) => n.category == 'buddy_request').toList();
    final unreadNotifications =
        notifications
            .where((n) => n.isUnread && n.category != 'buddy_request')
            .toList();
    final olderNotifications =
        notifications
            .where((n) => !n.isUnread && n.category != 'buddy_request')
            .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // New Buddy Requests Section
        if (buddyRequests.isNotEmpty) ...[
          _buildSectionHeader('New Buddy Requests', kAppRed),
          ...buddyRequests.map(
            (notification) => _buildNotificationItem(notification),
          ),
          const SizedBox(height: 16),
        ],

        // Unread Section
        if (unreadNotifications.isNotEmpty) ...[
          _buildSectionHeader('Unread', kAppPurple),
          ...unreadNotifications.map(
            (notification) => _buildNotificationItem(notification),
          ),
          const SizedBox(height: 16),
        ],

        // Older Section
        if (olderNotifications.isNotEmpty) ...[
          _buildSectionHeader('Older', kAppLightBlack),
          ...olderNotifications.map(
            (notification) => _buildNotificationItem(notification),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child:
            title == 'New Buddy Requests'
                ? GradientText(
                  text: title,
                  gradient: const LinearGradient(
                    colors: [kAppPurple, kAppOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                )
                : Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        if (notification.category == 'buddy_request') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BuddyRequestsScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kAppGreay, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification text with rich formatting
                  RichText(
                    text: TextSpan(
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: kAppBlack),
                      children: _buildRichTextSpans(notification.message),
                    ),
                  ),
                  if (notification.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.timestamp!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: kAppLightBlack),
                    ),
                  ],
                ],
              ),
            ),

            // Right side indicators and action button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Action button for special notifications
                if (notification.actionButtonText != null) ...[
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: notification.onActionButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAppPurple,
                        foregroundColor: kAppWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        notification.actionButtonText!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kAppWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Unread indicator (only for unread section)
                  if (notification.isUnread &&
                      notification.category != 'buddy_request')
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kAppRed,
                        shape: BoxShape.circle,
                      ),
                    ),

                  // Arrow indicator for buddy requests
                  if (notification.showArrow) ...[
                    if (notification.isUnread &&
                        notification.category != 'buddy_request')
                      const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: kAppLightBlack,
                      size: 16,
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildRichTextSpans(String message) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      // Add text before the bold part
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      // Add the bold part
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }
}
