import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/ratings_mock_data.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class RatingListItem extends StatelessWidget {
  final MockRating rating;
  final bool isCurrentUser;
  final VoidCallback? onDelete;

  const RatingListItem({
    Key? key,
    required this.rating,
    this.isCurrentUser = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final display = getRatingDisplay(rating.rating);
    return GestureDetector(
      onLongPress: isCurrentUser && onDelete != null ? onDelete : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Row(
          children: [
            ProfilePicture(
              imageUrl: rating.userImage,
              width: 22,
              height: 22,
              borderRadius: 5,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating.userName,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: kAppBlack,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${rating.rating}/5 | ${display.keyword}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(fontSize: 10, color: kAppBlack),
            ),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, color: display.color, size: 24),
          ],
        ),
      ),
    );
  }
}
