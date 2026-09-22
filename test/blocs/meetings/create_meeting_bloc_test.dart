import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/meetings/create_meeting_bloc.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/IntegratedMeetingsData.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for CreateMeetingBloc (getIntegratedMeetings -> getTeams ->
/// getProjects chain).
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<CreateMeetingBloc, CreateMeetingState>(
    'chain success -> [Integrated, Teams, Projects]',
    build: () {
      when(() => api.fetchIntegratedMeetings()).thenAnswer(
        (_) async =>
            IntegratedMeetingsData(status: true, data: [IntegratedMeetings()]),
      );
      when(() => api.fetchAllTeams()).thenAnswer(
        (_) async => AllTeamsRes(status: true, data: [AllTeamsData()]),
      );
      when(() => api.fetchAllProjects()).thenAnswer(
        (_) async => DashboardRes(status: true, data: [Data()]),
      );
      return CreateMeetingBloc(api);
    },
    act: (bloc) => bloc.add(const CreateMeetingDataRequested()),
    expect: () => [
      isA<CreateMeetingIntegratedLoaded>(),
      isA<CreateMeetingTeamsLoaded>(),
      isA<CreateMeetingProjectsLoaded>()
          .having((s) => s.projects.length, 'projects.length', 1),
    ],
  );

  blocTest<CreateMeetingBloc, CreateMeetingState>(
    'integrated network error stops the chain -> []',
    build: () {
      when(() => api.fetchIntegratedMeetings()).thenThrow(Exception('network'));
      return CreateMeetingBloc(api);
    },
    act: (bloc) => bloc.add(const CreateMeetingDataRequested()),
    expect: () => [],
  );
}
