import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/projects/projects_bloc.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for ProjectsBloc (mirrors the old `getProjects()`).
///
/// `isPushAvailable` is forced false so the push-only `getUserCats()` chain is
/// not exercised here (it needs a selected project + users/cats endpoints; it's
/// covered by the device smoke test).
void main() {
  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.userID = 1078;
    Strings.isPushAvailable = false;
  });

  blocTest<ProjectsBloc, ProjectsState>(
    'projects success -> [ProjectsLoading, ProjectsLoaded]',
    build: () {
      when(() => api.projects(any())).thenAnswer(
        (_) async => DashboardRes(
          status: true,
          message: 'ok',
          data: [Data(projectId: 1, projectName: 'Skyline Residency Tower')],
        ),
      );
      return ProjectsBloc(api);
    },
    act: (bloc) => bloc.add(const ProjectsRequested()),
    expect: () => [
      isA<ProjectsLoading>(),
      isA<ProjectsLoaded>()
          .having((s) => s.projects.length, 'projects.length', 1)
          .having((s) => s.projects.first.projectName, 'projectName',
              'Skyline Residency Tower'),
    ],
  );

  blocTest<ProjectsBloc, ProjectsState>(
    'projects empty (status false) -> [ProjectsLoading, ProjectsEmpty]',
    build: () {
      when(() => api.projects(any())).thenAnswer(
        (_) async =>
            DashboardRes(status: false, message: 'No Project found !!', data: []),
      );
      return ProjectsBloc(api);
    },
    act: (bloc) => bloc.add(const ProjectsRequested()),
    expect: () => [
      isA<ProjectsLoading>(),
      isA<ProjectsEmpty>()
          .having((s) => s.message, 'message', 'No Project found !!'),
    ],
  );

  blocTest<ProjectsBloc, ProjectsState>(
    'projects throws -> [ProjectsLoading, ProjectsLoadError]',
    build: () {
      when(() => api.projects(any())).thenThrow(Exception('network'));
      return ProjectsBloc(api);
    },
    act: (bloc) => bloc.add(const ProjectsRequested()),
    expect: () => [
      isA<ProjectsLoading>(),
      isA<ProjectsLoadError>(),
    ],
  );
}
