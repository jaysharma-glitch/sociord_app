import 'package:flutter/material.dart';

class MoveWithKeyboardElevatedBtn extends StatelessWidget {
  final onPressed;
  final child;
  final spaceFromBottom;
  const MoveWithKeyboardElevatedBtn(
      {super.key,
      required this.onPressed,
      required this.child,
      this.spaceFromBottom = 0.0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).viewInsets.bottom > 0
          ? MediaQuery.of(context).viewInsets.bottom
          : spaceFromBottom,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets.bottom > 0
              ? const EdgeInsets.all(0)
              : const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                        ? BorderRadius.zero
                        : BorderRadius.circular(50))),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
