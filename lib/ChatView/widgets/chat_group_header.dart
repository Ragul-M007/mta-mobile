
import 'package:flutter/material.dart';
import 'package:mta/ChatView/extensions/extensions.dart';

import '../chatview.dart';


class ChatGroupHeader extends StatelessWidget {
  const ChatGroupHeader({
    Key? key,
    required this.day,
    this.groupSeparatorConfig,
  }) : super(key: key);

  /// Provides day of started chat.
  final DateTime day;

  /// Provides configuration for separator upon date wise chat.
  final DefaultGroupSeparatorConfiguration? groupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: groupSeparatorConfig?.padding ??
          const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        day.getDay,
        textAlign: TextAlign.center,
        style: groupSeparatorConfig?.textStyle ?? const TextStyle(fontSize: 17),
      ),
    );
  }
}
