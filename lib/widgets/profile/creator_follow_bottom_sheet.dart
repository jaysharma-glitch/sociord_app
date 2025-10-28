import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class CreatorFollowBottomSheet extends StatelessWidget {
  final String creatorName;
  final VoidCallback? onUnfollow;
  final VoidCallback? onBlock;

  const CreatorFollowBottomSheet({
    super.key,
    required this.creatorName,
    this.onUnfollow,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: kAppBlack,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          // Unfollow option
          ListTile(
            leading: Icon(Icons.close, color: kAppBlack, size: 15),
            title: Text(
              'Unfollow $creatorName',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            onTap: () {
              onUnfollow?.call();
              Navigator.pop(context);
            },
          ),
          // Block user option
          ListTile(
            leading: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: kAppBlack,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_outlined,
                color: Colors.white,
                size: 10,
              ),
            ),
            title: Text(
              'Block $creatorName',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            onTap: () {
              onBlock?.call();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
