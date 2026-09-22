part of 'replies_bloc.dart';

abstract class RepliesEvent {
  const RepliesEvent();
}

class RepliesSocketInit extends RepliesEvent {
  final dynamic documentId;

  const RepliesSocketInit(this.documentId);
}

/// Register the `document-comments` handler (mirrors `getReplies()`).
class RepliesSubscribe extends RepliesEvent {
  const RepliesSubscribe();
}

class RepliesUserCatsRequested extends RepliesEvent {
  final int projectId;

  const RepliesUserCatsRequested(this.projectId);
}

class RepliesProjectRequested extends RepliesEvent {
  final int projectId;

  const RepliesProjectRequested(this.projectId);
}

class RepliesCatsRequested extends RepliesEvent {
  final int projectId;

  const RepliesCatsRequested(this.projectId);
}

class RepliesRemoveRequested extends RepliesEvent {
  final int commentId;

  const RepliesRemoveRequested(this.commentId);
}

class RepliesAudioRequested extends RepliesEvent {
  final AudioReq req;

  const RepliesAudioRequested(this.req);
}

/// Emit a reply (mirrors `postReplies()` → create-document-comment); [payload]
/// map (with parent_comment_id) built by the widget.
class RepliesPostEmit extends RepliesEvent {
  final dynamic payload;

  const RepliesPostEmit(this.payload);
}

class RepliesNotificationUpdate extends RepliesEvent {
  final dynamic notificationId;

  const RepliesNotificationUpdate(this.notificationId);
}

/// Disconnect the socket before opening the attach-file screen (mirrors the
/// attach-file onTap).
class RepliesDisconnect extends RepliesEvent {
  const RepliesDisconnect();
}

/// Internal: a `document-comments` payload arrived on the socket.
class RepliesDocReceived extends RepliesEvent {
  final dynamic data;

  const RepliesDocReceived(this.data);
}

/// Internal: the socket connected (initial).
class RepliesConnectedInternal extends RepliesEvent {
  const RepliesConnectedInternal();
}

/// Internal: the socket reconnected after a delete/audio.
class RepliesReconnectedInternal extends RepliesEvent {
  final bool audioUi;

  const RepliesReconnectedInternal(this.audioUi);
}
