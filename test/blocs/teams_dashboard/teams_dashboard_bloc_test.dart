import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/teams_dashboard/teams_dashboard_bloc.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for TeamsDashboardBloc (mirrors getTeams()). `isPushAvailable`
/// is false so the push-only getUserCats() chain is not exercised here.
void main() {
  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.isPushAvailable = false;
  });

  blocTest<TeamsDashboardBloc, TeamsDashboardState>(
    'teams success -> [TeamsLoading, TeamsLoaded]',
    build: () {
      when(() => api.fetchTeams()).thenAnswer(
        (_) async => TeamsModel(
          status: true,
          data: [TeamsData(teamId: 1, teamName: 'Site Engineers')],
        ),
      );
      return TeamsDashboardBloc(api);
    },
    act: (bloc) => bloc.add(const TeamsRequested()),
    expect: () => [
      isA<TeamsLoading>(),
      isA<TeamsLoaded>().having((s) => s.teams.length, 'teams.length', 1),
    ],
  );

  blocTest<TeamsDashboardBloc, TeamsDashboardState>(
    'teams empty (status false) -> [TeamsLoading, TeamsEmpty]',
    build: () {
      when(() => api.fetchTeams()).thenAnswer(
        (_) async =>
            TeamsModel(status: false, message: 'No teams found !!', data: []),
      );
      return TeamsDashboardBloc(api);
    },
    act: (bloc) => bloc.add(const TeamsRequested()),
    expect: () => [
      isA<TeamsLoading>(),
      isA<TeamsEmpty>().having((s) => s.message, 'message', 'No teams found !!'),
    ],
  );

  blocTest<TeamsDashboardBloc, TeamsDashboardState>(
    'teams throws -> [TeamsLoading, TeamsLoadError]',
    build: () {
      when(() => api.fetchTeams()).thenThrow(Exception('network'));
      return TeamsDashboardBloc(api);
    },
    act: (bloc) => bloc.add(const TeamsRequested()),
    expect: () => [isA<TeamsLoading>(), isA<TeamsLoadError>()],
  );
}
