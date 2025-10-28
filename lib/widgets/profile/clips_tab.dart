import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/clips_mock_data.dart';
import 'package:sociord/models/clip_model.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_reader_page.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_source.dart';

class ClipsTab extends StatefulWidget {
  const ClipsTab({super.key});

  @override
  State<ClipsTab> createState() => _ClipsTabState();
}

class _ClipsTabState extends State<ClipsTab> {
  bool isLandscapeMode = false;
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    final clips = ClipsMockData.getClipsByOrientation(isLandscapeMode);

    return Column(
      children: [
        // Header with toggle and sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              // Toggle switch for landscape/portrait
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton(
                      'Landscape',
                      !isLandscapeMode,
                      () => setState(() => isLandscapeMode = false),
                    ),
                    _buildToggleButton(
                      'Portrait',
                      isLandscapeMode,
                      () => setState(() => isLandscapeMode = true),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort by Rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: kAppBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: kAppBlack),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: isGridView ? _buildGridView(clips) : _buildListView(clips),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? kAppBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : kAppBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(List<ClipModel> clips) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: clips.length,
      itemBuilder: (context, index) {
        final clip = clips[index];
        return _buildClipCard(clip, isGrid: true);
      },
    );
  }

  Widget _buildListView(List<ClipModel> clips) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: clips.length,
      itemBuilder: (context, index) {
        final clip = clips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildClipCard(clip, isGrid: false),
        );
      },
    );
  }

  Widget _buildClipCard(ClipModel clip, {required bool isGrid}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => PostReaderPage(
                  userId: 'creator_1',
                  initialPostId: clip.id,
                  source: PostSource.uploads,
                  userName: 'Creator Name',
                  profileImage: 'assets/images/creator/1.jpeg',
                  isCreator: true, // This is creator content
                ),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: DecorationImage(
                    image: AssetImage(clip.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      clip.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kAppBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Stats
                    Row(
                      children: [
                        Icon(
                          clip.rating == 'Excellent'
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color:
                              clip.rating == 'Excellent'
                                  ? Colors.amber
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(clip.likes),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(clip.comments),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Views and time
                    Text(
                      '${clip.rating} | ${_formatNumber(clip.views)} Views | ${clip.timeAgo}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
