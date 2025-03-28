import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ProfileHighlight extends StatefulWidget {
  final isHighlightExpanded;
  final profileType;
  final dropDownClick;
  const ProfileHighlight(
      {super.key,
      required this.isHighlightExpanded,
      required this.profileType,
      required this.dropDownClick});

  @override
  State<ProfileHighlight> createState() => _ProfileHighlightState();
}

class _ProfileHighlightState extends State<ProfileHighlight> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.dropDownClick();
            });
          },
          child: Row(
            children: [
              Text(
                widget.profileType == 'Creator'
                    ? 'Arjun’s Showcase'
                    : 'Arjun’s Highlights',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 15, color: kAppPurple),
              ),
              const SizedBox(
                width: 5,
              ),
              AnimatedRotation(
                duration:
                    Duration(milliseconds: 100), // Smooth rotation animation
                turns: widget.isHighlightExpanded
                    ? 0.5
                    : 0, // 0.5 means 180-degree rotation
                child: Image.asset(kChevronDownPurple),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: widget.isHighlightExpanded ? null : 0,
          child: Visibility(
            visible: widget.isHighlightExpanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profileType == 'Creator'
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
                      const Icon(
                        Icons.add,
                        size: 35,
                        color: kAppPurple,
                      ),
                      Center(
                        child: Text(
                            widget.profileType == 'Creator'
                                ? 'Promoted a Brand? Share it here'
                                : 'Got Married? \nShare the memory',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontSize: 9, color: kAppPurple)),
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
