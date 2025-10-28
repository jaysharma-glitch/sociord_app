import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/toggle_button.dart';

class CollectionsHeader extends StatefulWidget {
  final ValueChanged<bool> onOrientationChanged;
  final bool initialValue;

  const CollectionsHeader({
    super.key,
    required this.onOrientationChanged,
    this.initialValue = false,
  });

  @override
  State<CollectionsHeader> createState() => _CollectionsHeaderState();
}

class _CollectionsHeaderState extends State<CollectionsHeader> {
  late bool _isHorizontalMode;

  @override
  void initState() {
    super.initState();
    _isHorizontalMode = widget.initialValue;
  }

  @override
  void didUpdateWidget(CollectionsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _isHorizontalMode = widget.initialValue;
      });
    }
  }

  void _toggleOrientation(bool isHorizontal) {
    if (_isHorizontalMode == isHorizontal) return; // No change
    setState(() {
      _isHorizontalMode = isHorizontal;
    });
    widget.onOrientationChanged(isHorizontal); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          // Toggle switch for portrait/landscape
          ToggleButton(
            firstOption: 'Portrait',
            secondOption: 'Landscape',
            initialValue:
                !_isHorizontalMode, // Invert: false=Portrait, true=Landscape
            onChanged: (isFirstOption) {
              // isFirstOption = true means Portrait is selected
              // isFirstOption = false means Landscape is selected
              // We want _isHorizontalMode = true when Portrait is selected
              _toggleOrientation(!isFirstOption);
            },
          ),
          const Spacer(),
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort by Newest',
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
    );
  }
}
