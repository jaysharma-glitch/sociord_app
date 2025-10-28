import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/chat_mock_data.dart';
import 'package:sociord/models/chat_message_model.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactUsername;
  final String contactProfileImage;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactUsername,
    required this.contactProfileImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiVisible = false;
  ChatMessage? _replyingToMessage;
  ChatMessage? _longPressedMessage;
  int? _longPressedMessageIndex;
  final Map<int, GlobalKey> _messageKeys = {};
  final Map<int, double> _messageDragOffsets = {};

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                _buildHeader(),

                // Messages
                Expanded(child: _buildMessages()),

                // Message input
                _buildMessageInput(),

                // Emoji picker
                if (_isEmojiVisible) _buildEmojiPicker(),
              ],
            ),

            // Blurred overlay with reaction and action widgets
            if (_longPressedMessage != null) _buildLongPressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kAppWhite,
        border: Border(bottom: BorderSide(color: kAppGreay, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: kAppBlack, size: 20),
          ),
          const SizedBox(width: 12),
          // Profile Picture
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              widget.contactProfileImage,
              width: 40,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Name and Username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kAppBlack,
                  ),
                ),
                Text(
                  widget.contactUsername,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: kAppLightBlack),
                ),
              ],
            ),
          ),

          // Action icons when message is selected
          if (_longPressedMessageIndex != null) ...[
            GestureDetector(
              onTap: _handleReply,
              child: const Icon(Icons.reply, color: kAppBlack, size: 24),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _handleCopy,
              child: const Icon(Icons.copy, color: kAppBlack, size: 24),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _handleDelete,
              child: const Icon(Icons.delete, color: kAppBlack, size: 24),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessages() {
    final messages = ChatMockData.getMessages();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastMessage = index == messages.length - 1;
        final showDateSeparator =
            index == 0 ||
            _shouldShowDateSeparator(messages[index - 1], message);

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(message.timestamp),
            _buildMessageBubble(message, index),
            if (isLastMessage) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kAppGreay.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDate(timestamp),
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: kAppLightBlack, fontSize: 12),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isMe = message.isFromMe;
    final isSelected = _longPressedMessageIndex == index;
    final dragOffset = _messageDragOffsets[index] ?? 0.0;

    // Create or get GlobalKey for this message
    if (!_messageKeys.containsKey(index)) {
      _messageKeys[index] = GlobalKey();
    }

    return GestureDetector(
      onLongPress: () => _handleLongPress(message, index),
      onDoubleTap: () => _handleDoubleTap(message),
      onPanStart: (details) => _handlePanStart(index),
      onPanUpdate: (details) => _handlePanUpdate(index, details),
      onPanEnd: (details) => _handlePanEnd(details, message, index),
      child: Transform.translate(
        offset: Offset(dragOffset, 0), // Only horizontal movement
        child: Container(
          key: _messageKeys[index],
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isMe
                                ? const Color(0xFFE8D5FF)
                                : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            isSelected
                                ? Border.all(color: kAppPurple, width: 2)
                                : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.replyToMessage != null)
                            _buildReplyPreview(message.replyToMessage!),
                          Text(
                            message.text,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.isRead ? Icons.done_all : Icons.done,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Reactions below message
              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildReactions(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactions(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          message.reactions.map((reaction) {
            return Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kAppGreay.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(reaction, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
    );
  }

  Widget _buildReplyPreview(
    ChatMessage replyToMessage, {
    bool showMargin = true,
  }) {
    // Use different colors based on who the original message was from
    final isOriginalFromMe = replyToMessage.isFromMe;
    final backgroundColor =
        !showMargin
            ? kAppPurple.withOpacity(0.25)
            : isOriginalFromMe
            ? kBorderGreay // Dark grey for my messages
            : kAppPurple.withOpacity(
              0.25,
            ); // Light purple for other user's messages

    final textColor = kAppBlack; // Purple text for other user's messages

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: showMargin ? const EdgeInsets.only(bottom: 5) : EdgeInsets.zero,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              showMargin
                  ? BorderRadius.circular(8)
                  : const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Responding to @${replyToMessage.isFromMe ? 'you' : widget.contactUsername}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kAppPurple,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyToMessage.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Cross button when margin is false
            if (!showMargin)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _replyingToMessage = null;
                    });
                  },
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: kAppWhite),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main input container with rounded background
          Expanded(
            child: Column(
              children: [
                if (_replyingToMessage != null) ...[
                  _buildReplyPreview(_replyingToMessage!, showMargin: false),
                ],
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120, // 5 lines * ~24px per line
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Light grey background
                    borderRadius:
                        _replyingToMessage != null
                            ? const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )
                            : BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Emoji button inside container
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEmojiVisible = !_isEmojiVisible;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isEmojiVisible
                                    ? Icons.keyboard
                                    : Icons.emoji_emotions_outlined,
                                color: kAppBlack,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),

                      // Text input area
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Bro, Don\'t Cancel !',
                            hintStyle: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: kAppLightBlack),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: kAppBlack),
                          maxLines: 5,
                          minLines: 1,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _showAttachmentOptions,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_file,
                                color: kAppBlack,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),
                      // Attachment button inside container
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Only show send button when there's text to send
          if (_messageController.text.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: kAppPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: kAppWhite, size: 24),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmojiPicker({bool isForReaction = false}) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          if (isForReaction) {
            // Handle emoji reaction
            HapticFeedback.lightImpact();
            print('Reacted with ${emoji.emoji}');
            Navigator.pop(context);
            _dismissLongPressOverlay();
          } else {
            // Handle message input
            _messageController.text += emoji.emoji;
            setState(() {});
          }
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28,
            backgroundColor: kAppWhite,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: Text(
              'No Recents',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kAppLightBlack),
            ),
            loadingIndicator: const SizedBox.shrink(),
            buttonMode: ButtonMode.MATERIAL,
          ),
          swapCategoryAndBottomBar: false,
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: kAppWhite,
            iconColorSelected: kAppPurple,
            backspaceColor: kAppPurple,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: kAppWhite,
            buttonColor: kAppPurple,
            buttonIconColor: kAppWhite,
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Send message logic
    print('Sending message: ${_messageController.text}');

    _messageController.clear();
    setState(() {});

    // Scroll to bottom
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Handle gallery
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(
                    'Camera',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Handle camera
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(
                    'Document',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Handle document
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _handleLongPress(ChatMessage message, int index) {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    // Small delay to ensure GlobalKey is properly set up
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _longPressedMessage = message;
          _longPressedMessageIndex = index;
        });
      }
    });
  }

  void _handleDoubleTap(ChatMessage message) {
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    // Add heart emoji reaction
    print('Double tapped - adding heart emoji to message: ${message.text}');
    // TODO: Add heart emoji to message reactions
  }

  void _handlePanStart(int index) {
    // Initialize drag offset if not exists
    if (!_messageDragOffsets.containsKey(index)) {
      _messageDragOffsets[index] = 0.0;
    }
  }

  void _handlePanUpdate(int index, DragUpdateDetails details) {
    final currentOffset = _messageDragOffsets[index] ?? 0.0;
    final newOffset = currentOffset + details.delta.dx;

    // Get the message to determine drag direction
    final messages = ChatMockData.getMessages();
    if (index < messages.length) {
      final message = messages[index];
      final isMe = message.isFromMe;

      // Restrict drag direction based on message sender
      if (isMe) {
        // My messages: only allow dragging to the left (negative values)
        if (newOffset <= 0) {
          setState(() {
            _messageDragOffsets[index] = newOffset;
          });
        }
      } else {
        // Other user's messages: only allow dragging to the right (positive values)
        if (newOffset >= 0) {
          setState(() {
            _messageDragOffsets[index] = newOffset;
          });
        }
      }
    }
  }

  void _handlePanEnd(DragEndDetails details, ChatMessage message, int index) {
    final currentOffset = _messageDragOffsets[index] ?? 0.0;
    final dragDistance = currentOffset.abs();
    final dragVelocity = details.velocity.pixelsPerSecond.dx.abs();

    // Check if it's a swipe to reply based on distance (40px) or velocity (100px/s)
    if (dragDistance >= 40 || dragVelocity > 100) {
      HapticFeedback.lightImpact();
      setState(() {
        _replyingToMessage = message;
        _messageDragOffsets[index] =
            0.0; // Reset position when reply is selected
      });
      print(
        'Swiped to reply to message: ${message.text} (distance: ${dragDistance.toStringAsFixed(1)}px, velocity: ${dragVelocity.toStringAsFixed(1)}px/s)',
      );
    } else {
      // Snap back to original position
      setState(() {
        _messageDragOffsets[index] = 0.0;
      });
    }
  }

  void _dismissLongPressOverlay() {
    if (!mounted) return;
    setState(() {
      _longPressedMessage = null;
      _longPressedMessageIndex = null;
    });
  }

  void _handleReply() {
    if (_longPressedMessage != null) {
      // TODO: Implement reply functionality
      print('Reply to: ${_longPressedMessage!.text}');
      _dismissLongPressOverlay();
    }
  }

  void _handleCopy() {
    if (_longPressedMessage != null) {
      // TODO: Implement copy functionality
      print('Copy: ${_longPressedMessage!.text}');
      _dismissLongPressOverlay();
    }
  }

  void _handleDelete() {
    if (_longPressedMessage != null) {
      // TODO: Implement delete functionality
      print('Delete: ${_longPressedMessage!.text}');
      _dismissLongPressOverlay();
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEmojiPicker(isForReaction: true),
    );
  }

  Widget _buildLongPressOverlay() {
    if (_longPressedMessageIndex == null || _longPressedMessage == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _dismissLongPressOverlay,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Position widgets relative to the selected message
            _buildPositionedWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedWidgets() {
    if (_longPressedMessageIndex == null || _longPressedMessage == null) {
      return const SizedBox.shrink();
    }

    final messageKey = _messageKeys[_longPressedMessageIndex];
    if (messageKey?.currentContext == null) {
      return const SizedBox.shrink();
    }

    try {
      final RenderBox messageBox =
          messageKey!.currentContext!.findRenderObject() as RenderBox;
      final messagePosition = messageBox.localToGlobal(Offset.zero);
      final messageSize = messageBox.size;

      final isMe = _longPressedMessage!.isFromMe;
      final screenWidth = MediaQuery.of(context).size.width;

      // Position emoji widget above the message
      double emojiTop = messagePosition.dy - 110;
      double actionTop = messagePosition.dy + messageSize.height - 65;

      // Horizontal positioning based on message alignment and widget width
      double emojiHorizontalPosition;
      double actionHorizontalPosition;

      if (isMe) {
        // Right-aligned messages - show widgets on the right side of screen
        emojiHorizontalPosition = 20; // Emoji widget is narrower
        actionHorizontalPosition = screenWidth - 140;
      } else {
        // Left-aligned messages - show widgets on the left side of screen
        emojiHorizontalPosition = 20;
        actionHorizontalPosition = 20;
      }

      // Ensure widgets don't go off screen
      emojiHorizontalPosition = emojiHorizontalPosition.clamp(
        10.0,
        screenWidth - 120.0,
      );
      actionHorizontalPosition = actionHorizontalPosition.clamp(
        10.0,
        screenWidth - 80.0,
      );
      emojiTop = emojiTop.clamp(
        50.0,
        MediaQuery.of(context).size.height - 200.0,
      );
      actionTop = actionTop.clamp(
        50.0,
        MediaQuery.of(context).size.height - 200.0,
      );

      return Stack(
        children: [
          // Emoji widget
          Positioned(
            left: emojiHorizontalPosition,
            top: emojiTop,
            child: _buildEmojiReactionWidget(isMe),
          ),

          // Action widget - commented out for now
          // Positioned(
          //   left: actionHorizontalPosition,
          //   top: actionTop,
          //   child: _buildActionWidget(isMe),
          // ),
        ],
      );
    } catch (e) {
      // If positioning fails, return empty widget
      return const SizedBox.shrink();
    }
  }

  Widget _buildEmojiReactionWidget(bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kAppWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...['❤️', '😍', '🎉', '👍', '😴', '😢', '😊', '🎊'].map((emoji) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Add reaction
                print('Reacted with $emoji');
                _dismissLongPressOverlay();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showEmojiPicker();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: kAppWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: kAppBlack, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionWidget(bool isMe) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     decoration: BoxDecoration(
  //       color: kAppWhite,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         _buildActionItem(Icons.reply, 'Reply', () {
  //           HapticFeedback.lightImpact();
  //           setState(() {
  //             _replyingToMessage = _longPressedMessage;
  //           });
  //           _dismissLongPressOverlay();
  //         }),
  //         _buildActionItem(Icons.copy, 'Copy', () {
  //           HapticFeedback.lightImpact();
  //           // TODO: Copy message
  //           print('Copy message');
  //           _dismissLongPressOverlay();
  //         }),
  //         _buildActionItem(Icons.delete, 'Delete', () {
  //           HapticFeedback.lightImpact();
  //           // TODO: Delete message
  //           print('Delete message');
  //           _dismissLongPressOverlay();
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildActionItem(IconData icon, String text, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 120,
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: kAppBlack, size: 20),
  //           const SizedBox(width: 12),
  //           Text(
  //             text,
  //             style: Theme.of(
  //               context,
  //             ).textTheme.bodyMedium!.copyWith(color: kAppBlack),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  bool _shouldShowDateSeparator(ChatMessage previous, ChatMessage current) {
    final prevDate = DateTime(
      previous.timestamp.year,
      previous.timestamp.month,
      previous.timestamp.day,
    );
    final currDate = DateTime(
      current.timestamp.year,
      current.timestamp.month,
      current.timestamp.day,
    );
    return prevDate != currDate;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }
}
