part of 'project_comments_replies_bloc.dart';

abstract class ProjectCommentsRepliesEvent {
  const ProjectCommentsRepliesEvent();
}

class ProjectCommentsRepliesSocketInit extends ProjectCommentsRepliesEvent {
  final int? projectId;

  const ProjectCommentsRepliesSocketInit(this.projectId);
}

/// Register the `project-comments` handler (mirrors `getReplies()`).
class ProjectCommentsRepliesSubscribe extends ProjectCommentsRepliesEvent {
  const ProjectCommentsRepliesSubscribe();
}

class ProjectCommentsRepliesUserCatsRequested
    extends ProjectCommentsRepliesEvent {
  final int projectId;

  const ProjectCommentsRepliesUserCatsRequested(this.projectId);
}

class ProjectCommentsRepliesProjectRequested
    extends ProjectCommentsRepliesEvent {
  final int projectId;

  const ProjectCommentsRepliesProjectRequested(this.projectId);
}

class ProjectCommentsRepliesCatsRequested extends ProjectCommentsRepliesEvent {
  final int projectId;

  const ProjectCommentsRepliesCatsRequested(this.projectId);
}

class ProjectCommentsRepliesRemoveRequested
    extends ProjectCommentsRepliesEvent {
  final int commentId;

  const ProjectCommentsRepliesRemoveRequested(this.commentId);
}

class ProjectCommentsRepliesAudioRequested extends ProjectCommentsRepliesEvent {
  final AudioReq req;

  const ProjectCommentsRepliesAudioRequested(this.req);
}

/// Emit a project-comment reply (mirrors `postReplies()` →
/// create-project-comment via emitWithAck); [payload] map built by the widget.
class ProjectCommentsRepliesPostEmit extends ProjectCommentsRepliesEvent {
  final dynamic payload;

  const ProjectCommentsRepliesPostEmit(this.payload);
}

class ProjectCommentsRepliesNotificationUpdate
    extends ProjectCommentsRepliesEvent {
  final dynamic notificationId;

  const ProjectCommentsRepliesNotificationUpdate(this.notificationId);
}

/// Disconnect the socket before opening the attach-file screen (mirrors the
/// attach-file onTap).
class ProjectCommentsRepliesDisconnect extends ProjectCommentsRepliesEvent {
  const ProjectCommentsRepliesDisconnect();
}

/// Internal: a `project-comments` payload arrived on the socket.
class ProjectCommentsRepliesDocReceived extends ProjectCommentsRepliesEvent {
  final dynamic data;

  const ProjectCommentsRepliesDocReceived(this.data);
}

/// Internal: the socket connected (initial).
class ProjectCommentsRepliesConnectedInternal
    extends ProjectCommentsRepliesEvent {
  const ProjectCommentsRepliesConnectedInternal();
}

/// Internal: the socket reconnected after a delete/audio.
class ProjectCommentsRepliesReconnectedInternal
    extends ProjectCommentsRepliesEvent {
  final bool audioUi;

  const ProjectCommentsRepliesReconnectedInternal(this.audioUi);
}
