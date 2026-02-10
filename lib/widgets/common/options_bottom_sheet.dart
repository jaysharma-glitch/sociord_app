import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/gradient_text.dart';

enum BottomSheetType {
  homepagePost,
  buddyFeedPost,
  exploreImmersivePost,
  profileOptions,
  selfProfilePersonal,
  selfProfileCreator,
  selfPostPersonal,
  selfPostCreator,
}

class OptionsBottomSheet {
  static void show({
    required BuildContext context,
    required BottomSheetType type,
    String? title,
    VoidCallback? onBack,
    Map<String, VoidCallback>? customActions,
    bool? isCreator, // Add parameter to determine if user is creator
    VoidCallback? onLogout, // Called when user taps Logout (self profile only)
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true, // Show above bottom nav
      builder:
          (context) => _OptionsBottomSheetContent(
            type: type,
            title: title,
            onBack: onBack,
            customActions: customActions,
            isCreator: isCreator,
            onLogout: onLogout,
          ),
    );
  }
}

class _OptionsBottomSheetContent extends StatelessWidget {
  final BottomSheetType type;
  final String? title;
  final VoidCallback? onBack;
  final Map<String, VoidCallback>? customActions;
  final bool? isCreator;
  final VoidCallback? onLogout;

  const _OptionsBottomSheetContent({
    required this.type,
    this.title,
    this.onBack,
    this.customActions,
    this.isCreator,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title (if provided)
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: onBack,
                      child: const Icon(Icons.arrow_back, color: kAppBlack),
                    ),
                  if (onBack != null) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: kAppBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Options list
          Flexible(child: _buildOptionsList(context)),

          // Contact Support
          _buildContactSupport(context),

          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    final options = _getOptionsForType(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildOptionItem(context, option);
      },
    );
  }

  Widget _buildOptionItem(BuildContext context, _OptionItem option) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: option.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          option.isGradientText
                              ? GradientText(
                                text: option.text,
                                gradient: const LinearGradient(
                                  colors: [kAppPurple, kAppOrange],
                                ),
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight
                                              .w600, // Purple text gets 600 weight
                                    ) ??
                                    const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                              )
                              : Text(
                                option.text,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: kAppBlack,
                                  fontWeight:
                                      FontWeight
                                          .w400, // Regular text gets 400 weight
                                ),
                              ),
                    ),
                    if (option.icon != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        option.icon,
                        color: option.iconColor ?? kAppBlack,
                        size: 20,
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: kAppLightBlack,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Add line between items
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement contact support
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Facing an issue ? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: kAppBlack,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: 'Contact Support',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: kAppPurple,
                            fontWeight:
                                FontWeight.w600, // Purple text gets 600 weight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: kAppLightBlack,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_OptionItem> _getOptionsForType(BuildContext context) {
    switch (type) {
      case BottomSheetType.homepagePost:
        return _getHomepagePostOptions(context);
      case BottomSheetType.buddyFeedPost:
        return _getBuddyFeedPostOptions(context);
      case BottomSheetType.exploreImmersivePost:
        return _getExploreImmersivePostOptions(context);
      case BottomSheetType.profileOptions:
        return _getProfileOptions(context);
      case BottomSheetType.selfProfilePersonal:
        return _getSelfProfilePersonalOptions(context);
      case BottomSheetType.selfProfileCreator:
        return _getSelfProfileCreatorOptions(context);
      case BottomSheetType.selfPostPersonal:
        return _getSelfPostPersonalOptions(context);
      case BottomSheetType.selfPostCreator:
        return _getSelfPostCreatorOptions(context);
    }
  }

  List<_OptionItem> _getHomepagePostOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'View profile',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to profile
        },
      ),
      _OptionItem(
        text: 'View subscription plans',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to subscription plans
        },
      ),
      _OptionItem(
        text: 'Hide this post',
        icon: Icons.visibility_off,
        onTap: () {
          Navigator.pop(context);
          // TODO: Hide post
        },
      ),
      _OptionItem(
        text: 'Not Interested',
        onTap: () {
          Navigator.pop(context);
          // TODO: Mark as not interested
        },
      ),
      _OptionItem(
        text: 'Report this post',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report post
        },
      ),
      _OptionItem(
        text: 'Report user',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report user
        },
      ),
      _OptionItem(
        text: 'Unfollow',
        onTap: () {
          Navigator.pop(context);
          // TODO: Unfollow user
        },
      ),
    ];
  }

  List<_OptionItem> _getBuddyFeedPostOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'View profile',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to profile
        },
      ),
      _OptionItem(
        text: 'Hide this post',
        icon: Icons.visibility_off,
        onTap: () {
          Navigator.pop(context);
          // TODO: Hide post
        },
      ),
      _OptionItem(
        text: 'Not Interested',
        onTap: () {
          Navigator.pop(context);
          // TODO: Mark as not interested
        },
      ),
      _OptionItem(
        text: 'Report this post',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report post
        },
      ),
      _OptionItem(
        text: 'Report user',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report user
        },
      ),
      _OptionItem(
        text: 'Remove from buddies',
        onTap: () {
          Navigator.pop(context);
          // TODO: Remove from buddies
        },
      ),
    ];
  }

  List<_OptionItem> _getExploreImmersivePostOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'View profile',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to profile
        },
      ),
      _OptionItem(
        text: 'Hide this post',
        icon: Icons.visibility_off,
        onTap: () {
          Navigator.pop(context);
          // TODO: Hide post
        },
      ),
      _OptionItem(
        text: 'Not Interested',
        onTap: () {
          Navigator.pop(context);
          // TODO: Mark as not interested
        },
      ),
      _OptionItem(
        text: 'Report this post',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report post
        },
      ),
      _OptionItem(
        text: 'Report user',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report user
        },
      ),
      _OptionItem(
        text: 'Unsubscribe',
        onTap: () {
          Navigator.pop(context);
          // TODO: Unsubscribe
        },
      ),
      _OptionItem(
        text: 'Unfollow',
        onTap: () {
          Navigator.pop(context);
          // TODO: Unfollow user
        },
      ),
    ];
  }

  List<_OptionItem> _getProfileOptions(BuildContext context) {
    return [
      // Show conditional profile view option based on user type
      if (isCreator == true)
        _OptionItem(
          text: 'View Creator Profile',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to creator profile
          },
        )
      else
        _OptionItem(
          text: 'View full profile',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to full profile
          },
        ),
      _OptionItem(
        text: 'Block Arjun',
        onTap: () {
          Navigator.pop(context);
          // TODO: Block user
        },
      ),
      _OptionItem(
        text: 'Report Arjun',
        icon: Icons.flag,
        iconColor: Colors.red,
        onTap: () {
          Navigator.pop(context);
          // TODO: Report user
        },
      ),
      _OptionItem(
        text: 'Remove from Buddies',
        onTap: () {
          Navigator.pop(context);
          // TODO: Remove from buddies
        },
      ),
    ];
  }

  List<_OptionItem> _getSelfProfilePersonalOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'Account Management',
        onTap: () {
          Navigator.pop(context);
          // TODO: Show account management sub-options
          _showAccountManagementOptions(context);
        },
      ),
      _OptionItem(
        text: 'Languages',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to languages
        },
      ),
      _OptionItem(
        text: 'Privacy Settings',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to privacy settings
        },
      ),
      _OptionItem(
        text: 'Terms and Conditions',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to terms and conditions
        },
      ),
      _OptionItem(
        text: 'Privacy Policy',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to privacy policy
        },
      ),
      _OptionItem(
        text: 'Become a Creator',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to become creator
        },
      ),
      _OptionItem(
        text: 'Logout',
        onTap: () {
          Navigator.pop(context);
          onLogout?.call();
        },
      ),
    ];
  }

  List<_OptionItem> _getSelfProfileCreatorOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'Account Management',
        onTap: () {
          Navigator.pop(context);
          // TODO: Show account management sub-options
          _showAccountManagementOptions(context);
        },
      ),
      _OptionItem(
        text: 'View Creator Dashboard',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to creator dashboard
        },
      ),
      _OptionItem(
        text: 'Privacy Settings',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to privacy settings
        },
      ),
      _OptionItem(
        text: 'Terms and Conditions',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to terms and conditions
        },
      ),
      _OptionItem(
        text: 'Privacy Policy',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to privacy policy
        },
      ),
      _OptionItem(
        text: 'Languages',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to languages
        },
      ),
      _OptionItem(
        text: 'Logout',
        onTap: () {
          Navigator.pop(context);
          onLogout?.call();
        },
      ),
    ];
  }

  List<_OptionItem> _getSelfPostPersonalOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'Core Memory ? Add to highlights',
        isGradientText: true,
        onTap: () {
          Navigator.pop(context);
          // TODO: Add to highlights
        },
      ),
      _OptionItem(
        text: 'Share post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Share post
        },
      ),
      _OptionItem(
        text: 'Archive Post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Archive post
        },
      ),
      _OptionItem(
        text: 'Edit Title',
        onTap: () {
          Navigator.pop(context);
          // TODO: Edit title
        },
      ),
      _OptionItem(
        text: 'Delete this post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Delete post
        },
      ),
    ];
  }

  List<_OptionItem> _getSelfPostCreatorOptions(BuildContext context) {
    return [
      _OptionItem(
        text: 'Hire-worthy work ? Add to Showcase',
        isGradientText: true,
        onTap: () {
          Navigator.pop(context);
          // TODO: Add to showcase
        },
      ),
      _OptionItem(
        text: 'View Performance',
        onTap: () {
          Navigator.pop(context);
          // TODO: View performance
        },
      ),
      _OptionItem(
        text: 'View Rating',
        onTap: () {
          Navigator.pop(context);
          // TODO: View rating
        },
      ),
      _OptionItem(
        text: 'Share post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Share post
        },
      ),
      _OptionItem(
        text: 'Archive Post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Archive post
        },
      ),
      _OptionItem(
        text: 'Edit Title',
        onTap: () {
          Navigator.pop(context);
          // TODO: Edit title
        },
      ),
      _OptionItem(
        text: 'Delete this post',
        onTap: () {
          Navigator.pop(context);
          // TODO: Delete post
        },
      ),
    ];
  }

  void _showAccountManagementOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AccountManagementBottomSheet(),
    );
  }
}

class _AccountManagementBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: kAppBlack),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Account Management',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: kAppBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Options list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _accountManagementOptions.length,
              itemBuilder: (context, index) {
                final option = _accountManagementOptions[index];
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: option.onTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontSize: 15,
                                      color: kAppBlack,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kAppLightBlack,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add line between items
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  ],
                );
              },
            ),
          ),

          // Contact Support
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement contact support
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Facing an issue ? ',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: kAppBlack,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: 'Contact Support',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: kAppPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: kAppLightBlack,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  final List<_OptionItem> _accountManagementOptions = [
    _OptionItem(
      text: 'Account Information',
      onTap: () {
        // TODO: Navigate to account information
      },
    ),
    _OptionItem(
      text: 'Update Profile',
      onTap: () {
        // TODO: Navigate to update profile
      },
    ),
    _OptionItem(
      text: 'Security settings',
      onTap: () {
        // TODO: Navigate to security settings
      },
    ),
    _OptionItem(
      text: 'Delete your account',
      onTap: () {
        // TODO: Navigate to delete account
      },
    ),
  ];
}

class _OptionItem {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final bool isGradientText;

  _OptionItem({
    required this.text,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.isGradientText = false,
  });
}
