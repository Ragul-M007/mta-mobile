import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/projectcomments/project_comments_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ProjectDetails.dart' as pd;
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Project-Comments REST + notification + doc-forwarding
/// flows after their move into [ProjectCommentsBloc]. The live socket
/// connect/emit is verified on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AudioReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<ProjectCommentsBloc, ProjectCommentsState>(
    'fetchUsers success -> [UserCatsLoaded]',
    setUp: () {
      when(() => api.fetchUsers(any())).thenAnswer((_) async =>
          FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
    },
    build: () => ProjectCommentsBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsUserCatsRequested(10)),
    expect: () => [isA<ProjectCommentsUserCatsLoaded>()],
  );

  blocTest<ProjectCommentsBloc, ProjectCommentsState>(
    'getProjectName success -> [ProjectLoaded]',
    setUp: () {
      when(() => api.getProjectName(any())).thenAnswer((_) async =>
          pd.ProjectDetailsRes(
              status: true, data: [pd.Data(projectName: 'Acme')]));
    },
    build: () => ProjectCommentsBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsProjectRequested(10)),
    expect: () => [
      isA<ProjectCommentsProjectLoaded>().having((s) => s.name, 'name', 'Acme')
    ],
  );

  group('fetchCats (ProjectCommentsCatsRequested)', () {
    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'success -> [CatsLoaded]',
      setUp: () {
        when(() => api.fetchCats(any())).thenAnswer(
            (_) async => FetchMapedCatRes(status: true, data: [CatsData()]));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsCatsRequested(10)),
      expect: () => [isA<ProjectCommentsCatsLoaded>()],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'status false -> [Dismiss]',
      setUp: () {
        when(() => api.fetchCats(any()))
            .thenAnswer((_) async => FetchMapedCatRes(status: false));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsCatsRequested(10)),
      expect: () => [isA<ProjectCommentsDismiss>()],
    );
  });

  group('removeComment (ProjectCommentsRemoveRequested)', () {
    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'success -> [RemoveLoading, RemoveOk]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: true));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRemoveRequested(7)),
      expect: () =>
          [isA<ProjectCommentsRemoveLoading>(), isA<ProjectCommentsRemoveOk>()],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'status false -> [RemoveLoading, RemoveFail]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: false));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRemoveRequested(7)),
      expect: () => [
        isA<ProjectCommentsRemoveLoading>(),
        isA<ProjectCommentsRemoveFail>()
      ],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'throws -> [RemoveLoading, RemoveError]',
      setUp: () {
        when(() => api.removeComment(any())).thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRemoveRequested(7)),
      expect: () => [
        isA<ProjectCommentsRemoveLoading>(),
        isA<ProjectCommentsRemoveError>()
      ],
    );
  });

  group('uploadAudio (ProjectCommentsAudioRequested)', () {
    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'success -> [AudioOk]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: true, message: 'ok'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsAudioRequested(AudioReq())),
      expect: () => [isA<ProjectCommentsAudioOk>()],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'status false -> [AudioFail]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: false, message: 'bad'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsAudioRequested(AudioReq())),
      expect: () => [
        isA<ProjectCommentsAudioFail>().having((s) => s.message, 'msg', 'bad')
      ],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'throws -> [AudioError]',
      setUp: () {
        when(() => api.uploadAudio(any())).thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsAudioRequested(AudioReq())),
      expect: () => [isA<ProjectCommentsAudioError>()],
    );
  });

  group('updateNotification (ProjectCommentsNotificationUpdate)', () {
    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'status false -> [NotifFailure]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsNotificationUpdate(9)),
      expect: () => [isA<ProjectCommentsNotifFailure>()],
    );

    blocTest<ProjectCommentsBloc, ProjectCommentsState>(
      'throws -> [NotifError]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsNotificationUpdate(9)),
      expect: () => [isA<ProjectCommentsNotifError>()],
    );
  });

  blocTest<ProjectCommentsBloc, ProjectCommentsState>(
    'project-comments payload -> [DocLoaded]',
    build: () => ProjectCommentsBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsDocReceived([])),
    expect: () => [isA<ProjectCommentsDocLoaded>()],
  );
}
