import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/meeting_details_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/MeetingDetails.dart';
import 'package:mta/models/UpdateMeetingReq.dart';
import 'package:mta/models/cancelMeetingReq.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Meeting-Details flows after their move into
/// [MeetingDetailsBloc]: getMeetings (getMeetingById), updateMeeting,
/// cancelMeeting (deleteMeeting).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(UpdateMeetingReq());
    registerFallbackValue(CancelMeetingReq());
  });

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('getMeetings (MeetingDetailsLoadRequested)', () {
    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'success -> [Loading, Loaded]',
      setUp: () {
        when(() => api.getMeetingById(any())).thenAnswer(
          (_) async => MeetingDetailsRes(status: true, data: MeetingDetail()),
        );
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(const MeetingDetailsLoadRequested(7)),
      expect: () =>
          [isA<MeetingDetailsLoading>(), isA<MeetingDetailsLoaded>()],
      verify: (_) => verify(() => api.getMeetingById(7)).called(1),
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'status false -> [Loading, Dismiss]',
      setUp: () {
        when(() => api.getMeetingById(any()))
            .thenAnswer((_) async => MeetingDetailsRes(status: false));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(const MeetingDetailsLoadRequested(7)),
      expect: () =>
          [isA<MeetingDetailsLoading>(), isA<MeetingDetailsDismiss>()],
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'throws -> [Loading, Dismiss]',
      setUp: () {
        when(() => api.getMeetingById(any())).thenThrow(Exception('net'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(const MeetingDetailsLoadRequested(7)),
      expect: () =>
          [isA<MeetingDetailsLoading>(), isA<MeetingDetailsDismiss>()],
    );
  });

  group('updateMeeting (MeetingDetailsUpdateRequested)', () {
    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'success -> [UpdateSuccess]',
      setUp: () {
        when(() => api.updateMeeting(any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsUpdateRequested(UpdateMeetingReq())),
      expect: () => [isA<MeetingUpdateSuccess>()],
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'status false -> [UpdateFailure]',
      setUp: () {
        when(() => api.updateMeeting(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'bad'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsUpdateRequested(UpdateMeetingReq())),
      expect: () =>
          [isA<MeetingUpdateFailure>().having((s) => s.message, 'msg', 'bad')],
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'throws -> [UpdateError]',
      setUp: () {
        when(() => api.updateMeeting(any())).thenThrow(Exception('x'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsUpdateRequested(UpdateMeetingReq())),
      expect: () => [isA<MeetingUpdateError>()],
    );
  });

  group('cancelMeeting (MeetingDetailsCancelRequested)', () {
    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'success -> [CancelSuccess]',
      setUp: () {
        when(() => api.deleteMeeting(any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsCancelRequested(CancelMeetingReq())),
      expect: () => [isA<MeetingCancelSuccess>()],
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'status false -> [CancelFailure]',
      setUp: () {
        when(() => api.deleteMeeting(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsCancelRequested(CancelMeetingReq())),
      expect: () =>
          [isA<MeetingCancelFailure>().having((s) => s.message, 'msg', 'no')],
    );

    blocTest<MeetingDetailsBloc, MeetingDetailsState>(
      'throws -> [CancelError]',
      setUp: () {
        when(() => api.deleteMeeting(any())).thenThrow(Exception('x'));
      },
      build: () => MeetingDetailsBloc(api),
      act: (bloc) => bloc.add(MeetingDetailsCancelRequested(CancelMeetingReq())),
      expect: () => [isA<MeetingCancelError>()],
    );
  });
}
