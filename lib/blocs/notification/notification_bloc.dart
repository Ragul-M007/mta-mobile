import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/NotificationRes.dart';
import 'package:mta/network/ApiService.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// BLoC for the Notifications screen.
///
/// Behavior-preserving extraction of `getNotification()` and
/// `updateNotification()`. API calls and `print` logging move verbatim; the
/// spinner, `setState` of the top-level `_msgList`, toasts and the
/// notification-type navigation remain the widget's job via a stream listener.
/// (`getUserCats()` is left in place — its only call site is commented out.)
/// States are command-style (not Equatable): a status-update outcome repeats per
/// notification tapped and must re-fire the listener each time.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService _api;

  NotificationBloc(this._api) : super(NotificationInitial()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationStatusUpdated>(_onStatusUpdated);
  }

  // Mirrors getNotification()
  Future<void> _onRequested(
      NotificationsRequested event, Emitter<NotificationState> emit) async {
    emit(NotificationsLoading());
    try {
      final response = await _api.notification();
      print('categoiresResponse status ${response.toJson()}');
      if (response.status!) {
        emit(NotificationsLoaded(response.data!));
      } else {
        emit(NotificationsEmpty(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(NotificationsError());
    }
  }

  // Mirrors updateNotification()
  Future<void> _onStatusUpdated(
      NotificationStatusUpdated event, Emitter<NotificationState> emit) async {
    emit(NotificationUpdateLoading());
    try {
      final response = await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        emit(NotificationUpdated(event.toComments));
      } else {
        emit(NotificationUpdateFailed(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(NotificationUpdateError());
    }
  }
}
