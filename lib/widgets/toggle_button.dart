import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class ToggleButton extends StatefulWidget {
  final String firstOption;
  final String secondOption;
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const ToggleButton({
    super.key,
    required this.firstOption,
    required this.secondOption,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool _isFirstOptionSelected;

  @override
  void initState() {
    super.initState();
    _isFirstOptionSelected = widget.initialValue;
  }

  void _toggleSelection(bool isFirstOption) {
    if (_isFirstOptionSelected == isFirstOption) return; // No change
    setState(() {
      _isFirstOptionSelected = isFirstOption;
    });
    widget.onChanged(isFirstOption); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAppBlack.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(widget.firstOption, true),
          _buildToggleOption(widget.secondOption, false),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isFirstOption) {
    final isActive = _isFirstOptionSelected == isFirstOption;

    return GestureDetector(
      onTap: () => _toggleSelection(isFirstOption),
      child: Container(
        padding:
            text == "Landscape"
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 7)
                : const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? kBorderGreay : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child:
            text == "Landscape"
                ? ClipRRect(
                  child: Container(height: 12, width: 24, color: kAppDarkGreay),
                )
                : ClipRRect(
                  child: Container(height: 16, width: 11, color: kAppDarkGreay),
                ),
      ),
    );
  }
}
