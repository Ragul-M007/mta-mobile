import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/notification/notification_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/NotificationRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for NotificationBloc (getNotification / updateNotification).
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<NotificationBloc, NotificationState>(
    'notifications success -> [Loading, Loaded]',
    build: () {
      when(() => api.notification()).thenAnswer(
        (_) async => NotificationRes(status: true, data: [NotificationData()]),
      );
      return NotificationBloc(api);
    },
    act: (bloc) => bloc.add(const NotificationsRequested()),
    expect: () => [
      isA<NotificationsLoading>(),
      isA<NotificationsLoaded>()
          .having((s) => s.notifications.length, 'length', 1),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'notifications status false -> [Loading, Empty]',
    build: () {
      when(() => api.notification()).thenAnswer(
        (_) async => NotificationRes(status: false, message: 'none', data: []),
      );
      return NotificationBloc(api);
    },
    act: (bloc) => bloc.add(const NotificationsRequested()),
    expect: () => [
      isA<NotificationsLoading>(),
      isA<NotificationsEmpty>().having((s) => s.message, 'message', 'none'),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'status update success -> [UpdateLoading, Updated(toComments)]',
    build: () {
      when(() => api.updateNotificationStatus(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      return NotificationBloc(api);
    },
    act: (bloc) => bloc.add(const NotificationStatusUpdated(7, "comments")),
    expect: () => [
      isA<NotificationUpdateLoading>(),
      isA<NotificationUpdated>().having((s) => s.toComments, 'toComments', "comments"),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'status update false -> [UpdateLoading, UpdateFailed]',
    build: () {
      when(() => api.updateNotificationStatus(any()))
          .thenAnswer((_) async => CommonRes(status: false, message: 'bad'));
      return NotificationBloc(api);
    },
    act: (bloc) => bloc.add(const NotificationStatusUpdated(7, "comments")),
    expect: () => [
      isA<NotificationUpdateLoading>(),
      isA<NotificationUpdateFailed>().having((s) => s.message, 'message', 'bad'),
    ],
  );
}
