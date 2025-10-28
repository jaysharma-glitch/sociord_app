import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/messages_mock_data.dart';
import 'package:sociord/models/message_model.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/utils/routes.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String selectedTab = 'Personal';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Set<String> _selectedMessages = {};
  bool _isSelectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
      child: _isSearchVisible ? _buildSearchHeader() : _buildNormalHeader(),
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedMessages.clear();
              });
            } else {
              context.pop();
            }
          },
          child: const Icon(Icons.arrow_back_ios, color: kAppBlack, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _isSelectionMode ? '' : 'Messages',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: kAppBlack,
            ),
          ),
        ),
        if (_isSelectionMode) ...[
          GestureDetector(
            onTap: () {
              // TODO: Handle mute
              print('Mute tapped');
            },
            child: const Icon(
              Icons.notifications_off,
              color: kAppBlack,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // TODO: Handle delete
              print('Delete tapped');
            },
            child: const Icon(Icons.delete, color: kAppBlack, size: 24),
          ),
        ] else ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = true;
              });
              _searchFocusNode.requestFocus();
            },
            child: const Icon(Icons.search, color: kAppBlack, size: 24),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              context.go(newMessageRoute);
            },
            child: const Icon(Icons.edit, color: kAppBlack, size: 24),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kBorderGreay,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search icon
          SizedBox(
            width: 20,
            height: 20,
            child: Icon(Icons.search, color: Colors.grey, size: 16),
          ),
          const SizedBox(width: 8),
          // Search input field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onSubmitted: (value) {
                // TODO: Handle search
                print('Searching for: $value');
              },
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = false;
                _searchController.clear();
              });
              _searchFocusNode.unfocus();
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.close, color: Colors.black, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            ['Creator', 'Personal'].map((tab) {
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
    final messages = MessagesMockData.getMessagesForTab(selectedTab);

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(MessageItem message) {
    final isSelected = _selectedMessages.contains(message.username);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSelectionMode = true;
          _selectedMessages.add(message.username);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedMessages.remove(message.username);
              if (_selectedMessages.isEmpty) {
                _isSelectionMode = false;
              }
            } else {
              _selectedMessages.add(message.username);
            }
          });
        } else {
          context.push(
            chatRoute,
            extra: {
              'contactName': message.username,
              'contactUsername': message.username,
              'contactProfileImage': message.profileImage,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? kAppPurple.withValues(alpha: 0.1)
                  : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: kAppGreay, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          message.profileImage,
                          width: 50,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: kAppPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: kAppWhite,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Message content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              message.username,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: kAppBlack,
                              ),
                            ),
                            if (message.isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [kAppPurple, kAppOrange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (message.relationshipLabel != null) ...[
                              _buildRelationshipLabel(
                                message.relationshipLabel!,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.lastMessage,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(
                            color: kAppLightBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                message.timestamp,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: kAppLightBlack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipLabel(String label) {
    switch (label.toLowerCase()) {
      case 'subscriber':
        return GradientText(
          text: label,
          gradient: const LinearGradient(
            colors: [kAppPurple, kAppOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case 'follower':
        return Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: kAppDarkGreay,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case 'following':
        return Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: kAppOrange,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case 'subscribed':
        return Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: kAppPurple,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      default:
        return Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: kAppDarkGreay,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }
}
