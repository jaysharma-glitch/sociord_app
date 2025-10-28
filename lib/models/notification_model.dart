import 'package:flutter/material.dart';

class NotificationItem {
  final String message;
  final String? timestamp;
  final bool isUnread;
  final bool showArrow;
  final String category;
  final String? actionButtonText;
  final VoidCallback? onActionButtonTap;

  NotificationItem({
    required this.message,
    this.timestamp,
    this.isUnread = false,
    this.showArrow = false,
    required this.category,
    this.actionButtonText,
    this.onActionButtonTap,
  });
}
