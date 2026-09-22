import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/meeting_history_bloc.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for MeetingHistoryBloc (mirrors getMeetings()).
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<MeetingHistoryBloc, MeetingHistoryState>(
    'success -> [MeetingHistoryLoaded]',
    build: () {
      when(() => api.getMeetingHistory(any())).thenAnswer(
        (_) async => MeetingsDataRes(status: true, data: [MeetingsData()]),
      );
      return MeetingHistoryBloc(api);
    },
    act: (bloc) => bloc.add(const MeetingHistoryRequested('2026-09-18')),
    expect: () => [
      isA<MeetingHistoryLoaded>().having((s) => s.meetings.length, 'len', 1),
    ],
  );

  blocTest<MeetingHistoryBloc, MeetingHistoryState>(
    'status false -> [MeetingHistoryEmpty]',
    build: () {
      when(() => api.getMeetingHistory(any())).thenAnswer(
        (_) async => MeetingsDataRes(status: false, data: []),
      );
      return MeetingHistoryBloc(api);
    },
    act: (bloc) => bloc.add(const MeetingHistoryRequested('2026-09-18')),
    expect: () => [isA<MeetingHistoryEmpty>()],
  );
}
