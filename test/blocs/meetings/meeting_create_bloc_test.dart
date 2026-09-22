import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/meeting_create_bloc.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for MeetingCreateBloc (mirrors submitData -> createMeeting).
void main() {
  late MockApiService api;

  setUpAll(() => registerFallbackValue(AddMeetingReq()));
  setUp(() => api = MockApiService());

  blocTest<MeetingCreateBloc, MeetingCreateState>(
    'success -> [Loading, Created]',
    build: () {
      when(() => api.createMeeting(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      return MeetingCreateBloc(api);
    },
    act: (bloc) => bloc.add(MeetingSubmitted(AddMeetingReq())),
    expect: () => [isA<MeetingCreateLoading>(), isA<MeetingCreated>()],
  );

  blocTest<MeetingCreateBloc, MeetingCreateState>(
    'status false -> [Loading, Failed]',
    build: () {
      when(() => api.createMeeting(any()))
          .thenAnswer((_) async => CommonRes(status: false, message: 'bad'));
      return MeetingCreateBloc(api);
    },
    act: (bloc) => bloc.add(MeetingSubmitted(AddMeetingReq())),
    expect: () => [
      isA<MeetingCreateLoading>(),
      isA<MeetingCreateFailed>().having((s) => s.message, 'message', 'bad'),
    ],
  );

  blocTest<MeetingCreateBloc, MeetingCreateState>(
    'throws -> [Loading, Error]',
    build: () {
      when(() => api.createMeeting(any())).thenThrow(Exception('network'));
      return MeetingCreateBloc(api);
    },
    act: (bloc) => bloc.add(MeetingSubmitted(AddMeetingReq())),
    expect: () => [isA<MeetingCreateLoading>(), isA<MeetingCreateError>()],
  );
}
