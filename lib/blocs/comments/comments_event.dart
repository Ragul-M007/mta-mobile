part of 'comments_bloc.dart';

abstract class CommentsEvent {
  const CommentsEvent();
}

/// Create + connect the socket (mirrors the IO.io setup in initState()).
class CommentsSocketInit extends CommentsEvent {
  final dynamic documentId;

  const CommentsSocketInit(this.documentId);
}

/// Register the `document-comments` handler (mirrors `getComments()`).
class CommentsSubscribe extends CommentsEvent {
  const CommentsSubscribe();
}

/// Load taggable users (mirrors `getUserCats()` → fetchUsers).
class CommentsUserCatsRequested extends CommentsEvent {
  final int projectId;

  const CommentsUserCatsRequested(this.projectId);
}

/// Load the project name (mirrors `getProjectDetails()` → getProjectName).
class CommentsProjectRequested extends CommentsEvent {
  final int projectId;

  const CommentsProjectRequested(this.projectId);
}

/// Load taggable categories (mirrors `getuserCatgories()` → fetchCats).
class CommentsCatsRequested extends CommentsEvent {
  final int projectId;

  const CommentsCatsRequested(this.projectId);
}

/// Delete a comment (mirrors the removeComment dialog action).
class CommentsRemoveRequested extends CommentsEvent {
  final int commentId;

  const CommentsRemoveRequested(this.commentId);
}

/// Upload an audio comment (mirrors `sendAudio()` → uploadAudio); [req] built
/// by the widget.
class CommentsAudioRequested extends CommentsEvent {
  final AudioReq req;

  const CommentsAudioRequested(this.req);
}

/// Emit a text comment (mirrors `postComments()` → create-document-comment);
/// [payload] map built by the widget.
class CommentsPostEmit extends CommentsEvent {
  final dynamic payload;

  const CommentsPostEmit(this.payload);
}

/// Mark a notification read (mirrors `updateNotification()`).
class CommentsNotificationUpdate extends CommentsEvent {
  final dynamic notificationId;

  const CommentsNotificationUpdate(this.notificationId);
}

/// Internal: a `document-comments` payload arrived on the socket.
class CommentsDocReceived extends CommentsEvent {
  final dynamic data;

  const CommentsDocReceived(this.data);
}

/// Internal: the socket connected (initial).
class CommentsConnectedInternal extends CommentsEvent {
  const CommentsConnectedInternal();
}

/// Internal: the socket reconnected after a delete/audio.
class CommentsReconnectedInternal extends CommentsEvent {
  final bool audioUi;

  const CommentsReconnectedInternal(this.audioUi);
}
