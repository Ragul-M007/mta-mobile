part of 'notification_bloc.dart';

/// Command-style states (not Equatable) — a status-update outcome repeats per
/// notification tapped and must re-fire the widget's listener each time.
abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {}

// --- getNotification() ---

/// Show the spinner while loading notifications.
class NotificationsLoading extends NotificationState {}

/// Notifications loaded — dismiss spinner + set `_msgList`.
class NotificationsLoaded extends NotificationState {
  final List<NotificationData> notifications;

  NotificationsLoaded(this.notifications);
}

/// `status == false` — dismiss spinner, clear `_msgList`, error toast.
class NotificationsEmpty extends NotificationState {
  final String message;

  NotificationsEmpty(this.message);
}

/// Unexpected error loading (catchError) — dismiss spinner only.
class NotificationsError extends NotificationState {}

// --- updateNotification() ---

/// Show the spinner while marking a notification read.
class NotificationUpdateLoading extends NotificationState {}

/// Marked read — dismiss spinner and navigate by [toComments] type.
class NotificationUpdated extends NotificationState {
  final dynamic toComments;

  NotificationUpdated(this.toComments);
}

/// `status == false` on update — dismiss spinner + error toast.
class NotificationUpdateFailed extends NotificationState {
  final String message;

  NotificationUpdateFailed(this.message);
}

/// Unexpected error on update (catchError) — dismiss + "Unable to connect" toast.
class NotificationUpdateError extends NotificationState {}
