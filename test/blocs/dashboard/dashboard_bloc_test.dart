import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/dashboard/dashboard_bloc.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for DashboardBloc (mirrors getProjects() -> fetchProjectByTeams).
/// `isPushAvailable` false so the push-only getUserCats() chain is skipped.
void main() {
  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.selectedTeamId = 159;
    Strings.isPushAvailable = false;
  });

  blocTest<DashboardBloc, DashboardState>(
    'team projects success -> [DashboardLoading, DashboardLoaded]',
    build: () {
      when(() => api.fetchProjectByTeams(any())).thenAnswer(
        (_) async => DashboardRes(
          status: true,
          message: 'ok',
          data: [Data(projectId: 902, projectName: 'Green Valley Villas')],
        ),
      );
      return DashboardBloc(api);
    },
    act: (bloc) => bloc.add(const DashboardProjectsRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>().having((s) => s.projects.length, 'projects.length', 1),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'empty (status false) -> [DashboardLoading, DashboardEmpty]',
    build: () {
      when(() => api.fetchProjectByTeams(any())).thenAnswer(
        (_) async =>
            DashboardRes(status: false, message: 'No Projects Found', data: []),
      );
      return DashboardBloc(api);
    },
    act: (bloc) => bloc.add(const DashboardProjectsRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardEmpty>().having((s) => s.message, 'message', 'No Projects Found'),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'throws -> [DashboardLoading, DashboardLoadError]',
    build: () {
      when(() => api.fetchProjectByTeams(any())).thenThrow(Exception('network'));
      return DashboardBloc(api);
    },
    act: (bloc) => bloc.add(const DashboardProjectsRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardLoadError>()],
  );
}
