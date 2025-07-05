import 'package:flutter/material.dart';

class SociordDraggableSheet extends StatefulWidget {
  final Widget child;
  final double minChildSize;
  final double maxChildSize;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const SociordDraggableSheet({
    Key? key,
    required this.child,
    this.minChildSize = 0.6,
    this.maxChildSize = 0.88,
    this.onOpen,
    this.onClose,
  }) : super(key: key);

  @override
  State<SociordDraggableSheet> createState() => _SociordDraggableSheetState();
}

class _SociordDraggableSheetState extends State<SociordDraggableSheet> {
  late DraggableScrollableController _controller;
  double _lastSize = 0.88;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _lastSize,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      _isOpen = true;
      widget.onOpen?.call();
    });
    _controller.addListener(_handleSheetChange);
  }

  void _handleSheetChange() {
    final size = _controller.size;
    if (size <= widget.minChildSize + 0.01 && _isOpen) {
      _isOpen = false;
      widget.onClose?.call();
    } else if (size > widget.minChildSize + 0.01 && !_isOpen) {
      _isOpen = true;
      widget.onOpen?.call();
    }
    _lastSize = size;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSheetChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _lastSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: true,
      snapSizes: [widget.minChildSize, widget.maxChildSize],
      builder: (context, scrollController) {
        return widget.child;
      },
    );
  }
}

/// Usage:
/// SociordDraggableSheet(
///   child: YourBottomSheetContent(scrollController),
///   onOpen: () { ... },
///   onClose: () { ... },
/// )
