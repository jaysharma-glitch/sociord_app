import 'package:flutter/material.dart';
import 'package:sociord/mock_data/share_mock_data.dart';
import 'package:sociord/widgets/common/post_image.dart';

class ShareUserGridItem extends StatelessWidget {
  final MockShareUser user;
  final bool selected;
  final VoidCallback onTap;

  const ShareUserGridItem({
    Key? key,
    required this.user,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PostImage(imageUrl: user.userImage, borderRadius: 12),
                if (selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.userName,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
