import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/meetings_home_bloc.dart';
import 'package:mta/models/MeetingAccessRes.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for MeetingsHomeBloc (mirrors getProfile -> getMeetings +
/// getMeetingAccess).
void main() {
  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.userID = 1078;
  });

  blocTest<MeetingsHomeBloc, MeetingsHomeState>(
    'success -> [Loading, UpcomingMeetingsLoaded, MeetingAccessLoaded]',
    build: () {
      when(() => api.getUpcomingMeeting(any())).thenAnswer(
        (_) async => MeetingsDataRes(status: true, data: [MeetingsData()]),
      );
      when(() => api.getMeetingAccess(any())).thenAnswer(
        (_) async => MeetingAccessRes(status: true, data: Data(access: true)),
      );
      return MeetingsHomeBloc(api);
    },
    act: (bloc) => bloc.add(const MeetingsHomeRequested()),
    expect: () => [
      isA<MeetingsHomeLoading>(),
      isA<UpcomingMeetingsLoaded>()
          .having((s) => s.meetings.length, 'meetings.length', 1),
      isA<MeetingAccessLoaded>().having((s) => s.access, 'access', true),
    ],
  );

  blocTest<MeetingsHomeBloc, MeetingsHomeState>(
    'empty meetings -> [Loading, UpcomingMeetingsEmpty, MeetingAccessLoaded]',
    build: () {
      when(() => api.getUpcomingMeeting(any())).thenAnswer(
        (_) async => MeetingsDataRes(status: false, data: []),
      );
      when(() => api.getMeetingAccess(any())).thenAnswer(
        (_) async => MeetingAccessRes(status: true, data: Data(access: false)),
      );
      return MeetingsHomeBloc(api);
    },
    act: (bloc) => bloc.add(const MeetingsHomeRequested()),
    expect: () => [
      isA<MeetingsHomeLoading>(),
      isA<UpcomingMeetingsEmpty>(),
      isA<MeetingAccessLoaded>().having((s) => s.access, 'access', false),
    ],
  );
}
