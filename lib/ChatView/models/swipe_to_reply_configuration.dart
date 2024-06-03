
import 'package:flutter/material.dart';

class SwipeToReplyConfiguration {
  /// Used to give color of reply icon while swipe to reply.
  final Color? replyIconColor;

  /// Used to give animation duration while swipe to reply.
  final Duration? animationDuration;

  /// Provides callback when user swipe chat bubble from left side.
  final void Function(String message, String sendBy)? onLeftSwipe;

  /// Provides callback when user swipe chat bubble from right side.
  final void Function(String message, String sendBy)? onRightSwipe;

  const SwipeToReplyConfiguration({
    this.replyIconColor,
    this.animationDuration,
    this.onRightSwipe,
    this.onLeftSwipe,
  });
}
