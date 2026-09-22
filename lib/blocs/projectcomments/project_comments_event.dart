part of 'project_comments_bloc.dart';

abstract class ProjectCommentsEvent {
  const ProjectCommentsEvent();
}

class ProjectCommentsSocketInit extends ProjectCommentsEvent {
  final int? projectId;

  const ProjectCommentsSocketInit(this.projectId);
}

/// Register the `project-comments` handler (mirrors `getComments()`).
class ProjectCommentsSubscribe extends ProjectCommentsEvent {
  const ProjectCommentsSubscribe();
}

class ProjectCommentsUserCatsRequested extends ProjectCommentsEvent {
  final int projectId;

  const ProjectCommentsUserCatsRequested(this.projectId);
}

class ProjectCommentsProjectRequested extends ProjectCommentsEvent {
  final int projectId;

  const ProjectCommentsProjectRequested(this.projectId);
}

class ProjectCommentsCatsRequested extends ProjectCommentsEvent {
  final int projectId;

  const ProjectCommentsCatsRequested(this.projectId);
}

class ProjectCommentsRemoveRequested extends ProjectCommentsEvent {
  final int commentId;

  const ProjectCommentsRemoveRequested(this.commentId);
}

class ProjectCommentsAudioRequested extends ProjectCommentsEvent {
  final AudioReq req;

  const ProjectCommentsAudioRequested(this.req);
}

/// Emit a project comment (mirrors `postComments()` → create-project-comment);
/// [payload] map built by the widget.
class ProjectCommentsPostEmit extends ProjectCommentsEvent {
  final dynamic payload;

  const ProjectCommentsPostEmit(this.payload);
}

class ProjectCommentsNotificationUpdate extends ProjectCommentsEvent {
  final dynamic notificationId;

  const ProjectCommentsNotificationUpdate(this.notificationId);
}

/// Internal: a `project-comments` payload arrived on the socket.
class ProjectCommentsDocReceived extends ProjectCommentsEvent {
  final dynamic data;

  const ProjectCommentsDocReceived(this.data);
}

/// Internal: the socket connected (initial).
class ProjectCommentsConnectedInternal extends ProjectCommentsEvent {
  const ProjectCommentsConnectedInternal();
}

/// Internal: the socket reconnected after a delete/audio.
class ProjectCommentsReconnectedInternal extends ProjectCommentsEvent {
  final bool audioUi;

  const ProjectCommentsReconnectedInternal(this.audioUi);
}
