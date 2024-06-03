
import 'package:flutter/material.dart';

import '../chatview.dart';

class ProfileCircleConfiguration {
  /// Used to give padding to profile circle.
  final EdgeInsetsGeometry? padding;

  /// Provides image url of user
  final String? profileImageUrl;

  /// Used for give bottom padding to profile circle
  final double? bottomPadding;

  /// Used for give circle radius to profile circle
  final double? circleRadius;

  /// Provides callback when user tap on profile circle.
  final void Function(ChatUser)? onAvatarTap;

  /// Provides callback when user long press on profile circle.
  final void Function(ChatUser)? onAvatarLongPress;

  const ProfileCircleConfiguration({
    this.onAvatarTap,
    this.padding,
    this.profileImageUrl,
    this.bottomPadding,
    this.circleRadius,
    this.onAvatarLongPress,
  });
}
