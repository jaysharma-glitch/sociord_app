import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class BuddyFeedSheet extends StatefulWidget {
  final String imagePath;
  final String username;
  final String profileImage;
  final String caption;
  const BuddyFeedSheet({
    Key? key,
    required this.imagePath,
    required this.username,
    required this.profileImage,
    required this.caption,
  }) : super(key: key);

  @override
  State<BuddyFeedSheet> createState() => _BuddyFeedSheetState();
}

class _BuddyFeedSheetState extends State<BuddyFeedSheet> {
  final TextEditingController _messageController = TextEditingController();
  bool _showSend = false;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _showSend = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Main image with gradient overlay
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient overlay at bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 180,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black87,
                                  Colors.black,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom area: profile, caption, like, message
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(widget.profileImage),
                              radius: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _liked = !_liked;
                                });
                              },
                              child: Icon(
                                _liked ? Icons.favorite : Icons.favorite_border,
                                color: _liked ? kAppPurple : Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Send a message',
                                          hintStyle: TextStyle(
                                            color: Colors.white54,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    if (_showSend)
                                      GestureDetector(
                                        onTap: () {
                                          // Send message logic here
                                          _messageController.clear();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Icon(
                                            Icons.send,
                                            color: kAppPurple,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sociord',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'GibsonBold',
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
