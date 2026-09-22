part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load the notification list (mirrors `getNotification()`).
class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();
}

/// Mark a notification read then navigate by type (mirrors `updateNotification`).
class NotificationStatusUpdated extends NotificationEvent {
  final dynamic notificationId;
  final dynamic toComments;

  const NotificationStatusUpdated(this.notificationId, this.toComments);

  @override
  List<Object?> get props => [notificationId, toComments];
}
