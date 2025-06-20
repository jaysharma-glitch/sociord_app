import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ProfileHighlight extends StatelessWidget {
  final bool isExpanded;
  final String profileType;
  final VoidCallback onToggle;

  const ProfileHighlight({
    super.key,
    required this.isExpanded,
    required this.profileType,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCreator = profileType == 'Creator';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                isCreator ? 'Arjun’s Showcase' : 'Arjun’s Highlights',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 15, color: kAppPurple),
              ),
              const SizedBox(width: 5),
              AnimatedRotation(
                duration: const Duration(milliseconds: 100),
                turns: isExpanded ? 0.5 : 0,
                child: Image.asset(kChevronDownPurple),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? null : 0,
          child: Visibility(
            visible: isExpanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCreator
                      ? 'Highlight your key projects and brand collaborations right here'
                      : 'Capture your life’s highlights and relive your best moments.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 35, color: kAppPurple),
                      Center(
                        child: Text(
                          isCreator
                              ? 'Promoted a Brand? Share it here'
                              : 'Got Married? \nShare the memory',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 9, color: kAppPurple),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
