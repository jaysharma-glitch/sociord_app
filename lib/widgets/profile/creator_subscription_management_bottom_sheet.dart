import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class CreatorSubscriptionManagementBottomSheet extends StatelessWidget {
  final String creatorName;
  final VoidCallback? onViewPackages;
  final VoidCallback? onCancelSubscription;
  final VoidCallback? onEditSubscription;
  final VoidCallback? onAskCreator;
  final VoidCallback? onContactSupport;

  const CreatorSubscriptionManagementBottomSheet({
    super.key,
    required this.creatorName,
    this.onViewPackages,
    this.onCancelSubscription,
    this.onEditSubscription,
    this.onAskCreator,
    this.onContactSupport,
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // View packages option
          ListTile(
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 14,
                  color: kAppBlack,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: 'View packages – '),
                  TextSpan(
                    text: 'More Value, More Savings',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 14,
                      color: kAppPurple,
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: kAppBlack),
            onTap: () {
              onViewPackages?.call();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1, color: Colors.grey),

          // Cancel subscription option
          ListTile(
            title: Text(
              'Cancel Subscription',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 14,
                color: kAppBlack,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: kAppBlack),
            onTap: () {
              onCancelSubscription?.call();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1, color: Colors.grey),

          // Edit subscription option
          ListTile(
            title: Text(
              'Edit Subscription',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 14,
                color: kAppBlack,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: kAppBlack),
            onTap: () {
              onEditSubscription?.call();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1, color: Colors.grey),

          // Ask creator option
          ListTile(
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 14,
                  color: kAppBlack,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: 'Have a query ? '),
                  TextSpan(
                    text: 'Ask $creatorName',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 14,
                      color: kAppPurple,
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: kAppBlack),
            onTap: () {
              onAskCreator?.call();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1, color: Colors.grey),

          // Contact support option
          ListTile(
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 14,
                  color: kAppBlack,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: 'Facing an issue ? '),
                  TextSpan(
                    text: 'Contact Support',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 14,
                      color: kAppPurple,
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: kAppBlack),
            onTap: () {
              onContactSupport?.call();
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
