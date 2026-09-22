import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/members_selection_bloc.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/TeamUsersRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for MembersSelectionBloc (getTeamsUsers / getProjectUsers /
/// submitData -> createMeeting).
void main() {
  late MockApiService api;

  setUpAll(() => registerFallbackValue(AddMeetingReq()));
  setUp(() => api = MockApiService());

  blocTest<MembersSelectionBloc, MembersSelectionState>(
    'team users success -> [TeamUsersLoaded]',
    build: () {
      when(() => api.fetchTeamUsers(any()))
          .thenAnswer((_) async => TeamUsersRes(status: true, data: [UsersData()]));
      return MembersSelectionBloc(api);
    },
    act: (bloc) => bloc.add(const TeamUsersRequested(159)),
    expect: () => [
      isA<TeamUsersLoaded>().having((s) => s.users.length, 'users.length', 1),
    ],
  );

  blocTest<MembersSelectionBloc, MembersSelectionState>(
    'project users success -> [ProjectUsersLoaded]',
    build: () {
      when(() => api.fetchUsers(any())).thenAnswer(
        (_) async => FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]),
      );
      return MembersSelectionBloc(api);
    },
    act: (bloc) => bloc.add(const ProjectUsersRequested(902)),
    expect: () => [
      isA<ProjectUsersLoaded>().having((s) => s.users.length, 'users.length', 1),
    ],
  );

  blocTest<MembersSelectionBloc, MembersSelectionState>(
    'submit success -> [MembersSubmitLoading, MembersMeetingCreated]',
    build: () {
      when(() => api.createMeeting(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      return MembersSelectionBloc(api);
    },
    act: (bloc) => bloc.add(MembersMeetingSubmitted(AddMeetingReq())),
    expect: () => [isA<MembersSubmitLoading>(), isA<MembersMeetingCreated>()],
  );

  blocTest<MembersSelectionBloc, MembersSelectionState>(
    'submit status false -> [MembersSubmitLoading, MembersSubmitFailed]',
    build: () {
      when(() => api.createMeeting(any()))
          .thenAnswer((_) async => CommonRes(status: false, message: 'bad'));
      return MembersSelectionBloc(api);
    },
    act: (bloc) => bloc.add(MembersMeetingSubmitted(AddMeetingReq())),
    expect: () => [
      isA<MembersSubmitLoading>(),
      isA<MembersSubmitFailed>().having((s) => s.message, 'message', 'bad'),
    ],
  );
}
