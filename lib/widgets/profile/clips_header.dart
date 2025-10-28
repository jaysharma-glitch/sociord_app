import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/toggle_button.dart';

class ClipsHeader extends StatefulWidget {
  final ValueChanged<bool> onOrientationChanged;
  final bool initialValue;

  const ClipsHeader({
    super.key,
    required this.onOrientationChanged,
    this.initialValue = false,
  });

  @override
  State<ClipsHeader> createState() => _ClipsHeaderState();
}

class _ClipsHeaderState extends State<ClipsHeader> {
  late bool _isLandscapeMode; // Internal state for the toggle

  @override
  void initState() {
    super.initState();
    _isLandscapeMode = widget.initialValue;
  }

  @override
  void didUpdateWidget(ClipsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _isLandscapeMode = widget.initialValue;
      });
    }
  }

  void _toggleOrientation(bool isLandscape) {
    if (_isLandscapeMode == isLandscape) return; // No change
    setState(() {
      _isLandscapeMode = isLandscape;
    });
    widget.onOrientationChanged(isLandscape); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          // Toggle switch for landscape/portrait
          ToggleButton(
            firstOption: 'Portrait',
            secondOption: 'Landscape',
            initialValue:
                !_isLandscapeMode, // Invert: false=Portrait, true=Landscape
            onChanged: (isFirstOption) {
              // isFirstOption = true means Portrait is selected
              // isFirstOption = false means Landscape is selected
              // We want _isLandscapeMode = true when Landscape is selected
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
    );
  }
}
