import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart'; // Add import for route constants
import 'package:sociord/widgets/feed/feed_data.dart';
import 'package:sociord/widgets/feed/feed_item.dart';
import 'package:sociord/widgets/feed/feed_type.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class FeedSheet extends StatefulWidget {
  final FeedData feedData;
  final int initialIndex;

  const FeedSheet({super.key, required this.feedData, this.initialIndex = 0});

  @override
  State<FeedSheet> createState() => _FeedSheetState();
}

class _FeedSheetState extends State<FeedSheet> with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _cubeController;
  late Animation<double> _cubeAnimation;

  int _currentIndex = 0;
  int _currentUserIndex = 0;
  bool _isPaused = false;
  bool _isLiked = false;
  bool _wasPausedAndResumed = false;
  bool _isGestureInProgress = false;
  bool _isGoingBack = false;
  double _totalDragDistance = 0.0;
  double _dragDistance = 0.0;
  final TextEditingController _messageController = TextEditingController();

  // Track current post index for each user
  final Map<String, int> _userPostIndices = {};

  FeedItem get _currentItem => widget.feedData.items[_currentIndex];

  // Get current user's posts
  List<FeedItem> get _currentUserPosts {
    if (widget.feedData.type == FeedType.highlight) {
      // For highlights, use title to identify different highlights
      final currentTitle = _currentItem.title;
      return widget.feedData.items
          .where((item) => item.title == currentTitle)
          .toList();
    } else {
      // For buddy feed, use userName to identify different users
      final currentUsername = _currentItem.userName;
      return widget.feedData.items
          .where((item) => item.userName == currentUsername)
          .toList();
    }
  }

  int get _currentUserPostIndex {
    if (widget.feedData.type == FeedType.highlight) {
      // For highlights, use title to identify
      return _currentUserPosts.indexWhere(
        (post) => post.title == _currentItem.title,
      );
    } else {
      // For buddy feed, use imagePath to identify
      return _currentUserPosts.indexWhere(
        (post) => post.imagePath == _currentItem.imagePath,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeUserIndex();
    _timerController = AnimationController(
      duration: Duration(seconds: _getItemDuration(_currentItem)),
      vsync: this,
    );
    _cubeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cubeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cubeController, curve: Curves.easeInOut),
    );

    _startTimer();
    _timerController.addStatusListener(_onTimerComplete);
    _timerController.addListener(() {
      // Force rebuild to update progress bar
      setState(() {});
    });

    // Add listener to message controller to update send button state
    _messageController.addListener(() {
      setState(() {});
    });
  }

  int _getItemDuration(FeedItem item) {
    int duration = item.duration;
    // Cap video duration at 30 seconds
    if (item.isVideo && duration > 30) {
      duration = 30;
    }
    return duration;
  }

  void _startTimer() {
    if (!_isPaused) {
      _timerController.forward();
    }
  }

  void _onTimerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Only advance to next item if timer wasn't paused and resumed
      if (!_wasPausedAndResumed) {
        _nextItem();
      } else {
        // Reset the flag and restart timer for current item
        _wasPausedAndResumed = false;
        _timerController.reset();
        _startTimer();
      }
    }
  }

  void _nextItem() {
    if (_currentIndex < widget.feedData.items.length - 1) {
      setState(() {
        _currentIndex++;
        _timerController.reset();
        _timerController.duration = Duration(
          seconds: _getItemDuration(_currentItem),
        );
        _wasPausedAndResumed = false;
      });
      _startTimer();
    } else {
      // Loop back to first item
      setState(() {
        _currentIndex = 0;
        _timerController.reset();
        _timerController.duration = Duration(
          seconds: _getItemDuration(_currentItem),
        );
        _wasPausedAndResumed = false;
      });
      _startTimer();
    }
  }

  void _previousItem() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _timerController.reset();
        _timerController.duration = Duration(
          seconds: _getItemDuration(_currentItem),
        );
        _wasPausedAndResumed = false;
      });
      _startTimer();
    } else {
      // Loop to last item
      setState(() {
        _currentIndex = widget.feedData.items.length - 1;
        _timerController.reset();
        _timerController.duration = Duration(
          seconds: _getItemDuration(_currentItem),
        );
        _wasPausedAndResumed = false;
      });
      _startTimer();
    }
  }

  void _switchToUser(int userIndex) {
    if (userIndex != _currentUserIndex) {
      // Save current position before switching
      if (widget.feedData.type == FeedType.highlight) {
        // For highlights, use title to identify
        final currentTitle = _currentItem.title ?? '';
        _userPostIndices[currentTitle] = _currentUserPostIndex;
      } else {
        // For buddy feed, use userName to identify
        final currentUsername = _currentItem.userName ?? '';
        _userPostIndices[currentUsername] = _currentUserPostIndex;
      }

      _cubeController.forward().then((_) {
        setState(() {
          _currentUserIndex = userIndex;
          _currentIndex = userIndex;

          // Restore saved position for the new user/highlight, or start from 0
          if (widget.feedData.type == FeedType.highlight) {
            // For highlights, use title to identify
            final newTitle = widget.feedData.items[userIndex].title ?? '';
            final savedIndex = _userPostIndices[newTitle] ?? 0;

            // Find the correct post index for the saved position
            int targetIndex = userIndex;
            for (int i = 0; i < savedIndex; i++) {
              if (targetIndex + 1 < widget.feedData.items.length &&
                  widget.feedData.items[targetIndex + 1].title == newTitle) {
                targetIndex++;
              } else {
                break;
              }
            }
            _currentIndex = targetIndex;
          } else {
            // For buddy feed, use userName to identify
            final newUsername = widget.feedData.items[userIndex].userName ?? '';
            final savedIndex = _userPostIndices[newUsername] ?? 0;

            // Find the correct post index for the saved position
            int targetIndex = userIndex;
            for (int i = 0; i < savedIndex; i++) {
              if (targetIndex + 1 < widget.feedData.items.length &&
                  widget.feedData.items[targetIndex + 1].userName ==
                      newUsername) {
                targetIndex++;
              } else {
                break;
              }
            }
            _currentIndex = targetIndex;
          }

          _timerController.reset();
          _timerController.duration = Duration(
            seconds: _getItemDuration(_currentItem),
          );
        });
        _cubeController.reset();
        _startTimer();
      });
    }
  }

  void _switchToNextUser() {
    if (widget.feedData.type == FeedType.highlight) {
      // For highlights, use title to identify different highlights
      final currentTitle = _currentItem.title;
      int nextHighlightIndex = -1;

      // Find the next highlight
      for (int i = _currentIndex + 1; i < widget.feedData.items.length; i++) {
        if (widget.feedData.items[i].title != currentTitle) {
          nextHighlightIndex = i;
          break;
        }
      }

      // If no next highlight found, loop to first highlight
      if (nextHighlightIndex == -1) {
        for (int i = 0; i < widget.feedData.items.length; i++) {
          if (widget.feedData.items[i].title != currentTitle) {
            nextHighlightIndex = i;
            break;
          }
        }
      }

      if (nextHighlightIndex != -1) {
        _isGoingBack = false; // Going forward
        _switchToUser(nextHighlightIndex);
      }
    } else {
      // For buddy feed, use userName to identify different users
      final currentUsername = _currentItem.userName;
      int nextUserIndex = -1;

      // Find the next user with posts
      for (int i = _currentIndex + 1; i < widget.feedData.items.length; i++) {
        if (widget.feedData.items[i].userName != currentUsername) {
          nextUserIndex = i;
          break;
        }
      }

      // If no next user found, loop to first user
      if (nextUserIndex == -1) {
        for (int i = 0; i < widget.feedData.items.length; i++) {
          if (widget.feedData.items[i].userName != currentUsername) {
            nextUserIndex = i;
            break;
          }
        }
      }

      if (nextUserIndex != -1) {
        _isGoingBack = false; // Going forward
        _switchToUser(nextUserIndex);
      }
    }
  }

  void _switchToPreviousUser() {
    if (widget.feedData.type == FeedType.highlight) {
      // For highlights, use title to identify different highlights
      final currentTitle = _currentItem.title;
      int previousHighlightIndex = -1;

      // Find the previous highlight
      for (int i = _currentIndex - 1; i >= 0; i--) {
        if (widget.feedData.items[i].title != currentTitle) {
          previousHighlightIndex = i;
          break;
        }
      }

      // If no previous highlight found, loop to last highlight
      if (previousHighlightIndex == -1) {
        for (int i = widget.feedData.items.length - 1; i >= 0; i--) {
          if (widget.feedData.items[i].title != currentTitle) {
            previousHighlightIndex = i;
            break;
          }
        }
      }

      if (previousHighlightIndex != -1) {
        _isGoingBack = true; // Going backward
        _switchToUser(previousHighlightIndex);
      }
    } else {
      // For buddy feed, use userName to identify different users
      final currentUsername = _currentItem.userName;
      int previousUserIndex = -1;

      // Find the previous user with posts
      for (int i = _currentIndex - 1; i >= 0; i--) {
        if (widget.feedData.items[i].userName != currentUsername) {
          previousUserIndex = i;
          break;
        }
      }

      // If no previous user found, loop to last user
      if (previousUserIndex == -1) {
        for (int i = widget.feedData.items.length - 1; i >= 0; i--) {
          if (widget.feedData.items[i].userName != currentUsername) {
            previousUserIndex = i;
            break;
          }
        }
      }

      if (previousUserIndex != -1) {
        _isGoingBack = true; // Going backward
        _switchToUser(previousUserIndex);
      }
    }
  }

  void _initializeUserIndex() {
    if (widget.feedData.type == FeedType.highlight) {
      // For highlights, use title to identify
      final currentTitle = _currentItem.title;
      for (int i = 0; i < widget.feedData.items.length; i++) {
        if (widget.feedData.items[i].title == currentTitle) {
          _currentUserIndex = i;
          break;
        }
      }
    } else {
      // For buddy feed, use userName to identify
      final currentUsername = _currentItem.userName;
      for (int i = 0; i < widget.feedData.items.length; i++) {
        if (widget.feedData.items[i].userName == currentUsername) {
          _currentUserIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _cubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'feed_${widget.feedData.type}_${_currentIndex}',
      child: Material(
        clipBehavior: Clip.hardEdge,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _cubeAnimation,
            builder: (context, child) {
              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..translate(
                        _isGoingBack
                            ? MediaQuery.of(context).size.width / 2
                            : -MediaQuery.of(context).size.width / 2,
                        0.0,
                        0.0,
                      ) // Move to edge based on direction
                      ..rotateY(
                        _isGoingBack
                            ? -_cubeAnimation.value * 1.5708
                            : _cubeAnimation.value * 1.5708,
                      ) // Rotate based on direction
                      ..translate(
                        _isGoingBack
                            ? -MediaQuery.of(context).size.width / 2
                            : MediaQuery.of(context).size.width / 2,
                        0.0,
                        0.0,
                      ), // Move back to center
                alignment: Alignment.center,
                child: Column(
                  children: [
                    // Header at the very top
                    Container(
                      color: kAppWhite,
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 0,
                        right: 0,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Image.asset(kLogoText, height: 28),
                          const SizedBox(width: 5),
                          Image.asset(kChevronDown),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 26,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    // Main content with gestures (image area only)
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => _pauseTimer(),
                        onTapUp: (_) => _resumeTimer(),
                        onTapCancel: () => _resumeTimer(),
                        onLongPressStart: (_) => _pauseTimer(),
                        onLongPressEnd: (_) => _resumeTimer(),
                        onPanStart: (_) => _pauseTimer(),
                        onPanUpdate: (details) {
                          if (details.delta.dy.abs() > details.delta.dx.abs()) {
                            // Vertical gesture - close sheet
                            _totalDragDistance += details.delta.dy.abs();
                            if (_totalDragDistance.abs() > 100) {
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Horizontal gesture - switch users
                            if (details.delta.dx.abs() > 50) {
                              if (details.delta.dx > 0) {
                                // Swipe right - go to previous user
                                _switchToPreviousUser();
                              } else {
                                // Swipe left - go to next user
                                _switchToNextUser();
                              }
                            }
                          }
                        },
                        onPanEnd: (_) {
                          _totalDragDistance = 0;
                          _resumeTimer();
                        },
                        child: Stack(
                          children: [
                            // Current item image
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.asset(
                                _currentItem.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Progress bars
                            Positioned(
                              top: 15,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: _buildProgressBars(),
                              ),
                            ),

                            // Bottom fade effect for smooth transition
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 20,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white30,
                                      kAppWhite,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Navigation areas
                            Positioned.fill(
                              child: Row(
                                children: [
                                  // Left side - previous post or user
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (_currentUserPostIndex > 0) {
                                          _previousItem();
                                        } else {
                                          _switchToPreviousUser();
                                        }
                                      },
                                      child: Container(),
                                    ),
                                  ),
                                  // Right side - next post or user
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (_currentUserPostIndex <
                                            _currentUserPosts.length - 1) {
                                          _nextItem();
                                        } else {
                                          _switchToNextUser();
                                        }
                                      },
                                      child: Container(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom content
                    _buildBottomContent(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    final currentUserPosts = _currentUserPosts;
    return Row(
      children: List.generate(currentUserPosts.length, (index) {
        final isActive = index == _currentUserPostIndex;
        final progress = isActive ? _timerController.value : 0.0;

        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(
              right: index < currentUserPosts.length - 1 ? 5 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomContent() {
    return Container(
      color: kAppWhite,
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePicture(
                imageUrl:
                    _currentItem.profileImage ?? widget.feedData.profileImage,
                width: 30,
                height: 35,
                borderRadius: 5,
                onTap: () {
                  _navigateToProfile(context);
                },
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _navigateToProfile(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentItem.userName ?? widget.feedData.userName,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    if (widget.feedData.type == FeedType.highlight) ...[
                      const SizedBox(height: 2),
                      Text(
                        _currentItem.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: kAppPurple,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      _currentItem.caption,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? kAppPurple : kAppBlack,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 60,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: kAppWhite,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kBorderGreay, width: 1),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: kAppBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(
                        color: kAppBlack.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) {
                      if (_messageController.text.isNotEmpty) {
                        _messageController.clear();
                      }
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              if (_messageController.text.isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kAppPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      _messageController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _pauseTimer() {
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
        _wasPausedAndResumed = true;
      });
      _timerController.stop();
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
    }
  }

  void _navigateToProfile(BuildContext context) {
    // Map buddy usernames to creator usernames for navigation
    final creatorUsernames = {
      'emma.wave': 'sarah.creative',
      'oliver_in_focus': 'alex.tech',
      'liamdavis': 'maya.fitness',
      'diya.codes': 'david.food',
      'noah.the.explorer': 'lisa.travel',
      'amara.now': 'james.art',
    };

    final username = _currentItem.userName ?? widget.feedData.userName;
    final creatorUsername = creatorUsernames[username];

    if (creatorUsername != null) {
      // Navigate to creator profile
      context.go(
        '$creatorProfileRoute?username=$creatorUsername&profileImage=${_currentItem.profileImage}&relationship=none',
      );
    } else {
      // Navigate to buddy profile (fallback)
      context.go(
        '$buddyProfileRoute?username=$username&profileImage=${_currentItem.profileImage}&relationship=none',
      );
    }
  }
}
