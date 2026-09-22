import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/projectcomments/project_comments_replies_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ProjectDetails.dart' as pd;
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Project-Comment Replies REST + notification +
/// doc-forwarding flows after their move into [ProjectCommentsRepliesBloc]. The
/// live socket connect/emit is verified on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AudioReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
    'fetchUsers success -> [UserCatsLoaded]',
    setUp: () {
      when(() => api.fetchUsers(any())).thenAnswer((_) async =>
          FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
    },
    build: () => ProjectCommentsRepliesBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsRepliesUserCatsRequested(10)),
    expect: () => [isA<ProjectCommentsRepliesUserCatsLoaded>()],
  );

  blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
    'getProjectName success -> [ProjectLoaded]',
    setUp: () {
      when(() => api.getProjectName(any())).thenAnswer((_) async =>
          pd.ProjectDetailsRes(
              status: true, data: [pd.Data(projectName: 'Acme')]));
    },
    build: () => ProjectCommentsRepliesBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsRepliesProjectRequested(10)),
    expect: () => [
      isA<ProjectCommentsRepliesProjectLoaded>()
          .having((s) => s.name, 'name', 'Acme')
    ],
  );

  group('fetchCats (ProjectCommentsRepliesCatsRequested)', () {
    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'success -> [CatsLoaded]',
      setUp: () {
        when(() => api.fetchCats(any())).thenAnswer(
            (_) async => FetchMapedCatRes(status: true, data: [CatsData()]));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesCatsRequested(10)),
      expect: () => [isA<ProjectCommentsRepliesCatsLoaded>()],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'status false -> [Dismiss]',
      setUp: () {
        when(() => api.fetchCats(any()))
            .thenAnswer((_) async => FetchMapedCatRes(status: false));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesCatsRequested(10)),
      expect: () => [isA<ProjectCommentsRepliesDismiss>()],
    );
  });

  group('removeComment (ProjectCommentsRepliesRemoveRequested)', () {
    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'success -> [RemoveLoading, RemoveOk]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: true));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesRemoveRequested(7)),
      expect: () => [
        isA<ProjectCommentsRepliesRemoveLoading>(),
        isA<ProjectCommentsRepliesRemoveOk>()
      ],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'status false -> [RemoveLoading, RemoveFail]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: false));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesRemoveRequested(7)),
      expect: () => [
        isA<ProjectCommentsRepliesRemoveLoading>(),
        isA<ProjectCommentsRepliesRemoveFail>()
      ],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'throws -> [RemoveLoading, RemoveError]',
      setUp: () {
        when(() => api.removeComment(any())).thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesRemoveRequested(7)),
      expect: () => [
        isA<ProjectCommentsRepliesRemoveLoading>(),
        isA<ProjectCommentsRepliesRemoveError>()
      ],
    );
  });

  group('uploadAudio (ProjectCommentsRepliesAudioRequested)', () {
    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'success -> [AudioOk]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: true, message: 'ok'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsRepliesAudioRequested(AudioReq())),
      expect: () => [isA<ProjectCommentsRepliesAudioOk>()],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'status false -> [AudioFail]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: false, message: 'bad'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsRepliesAudioRequested(AudioReq())),
      expect: () => [
        isA<ProjectCommentsRepliesAudioFail>()
            .having((s) => s.message, 'msg', 'bad')
      ],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'throws -> [AudioError]',
      setUp: () {
        when(() => api.uploadAudio(any())).thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(ProjectCommentsRepliesAudioRequested(AudioReq())),
      expect: () => [isA<ProjectCommentsRepliesAudioError>()],
    );
  });

  group('updateNotification (ProjectCommentsRepliesNotificationUpdate)', () {
    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'status false -> [NotifFailure]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesNotificationUpdate(9)),
      expect: () => [isA<ProjectCommentsRepliesNotifFailure>()],
    );

    blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
      'throws -> [NotifError]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenThrow(Exception('x'));
      },
      build: () => ProjectCommentsRepliesBloc(api),
      act: (bloc) => bloc.add(const ProjectCommentsRepliesNotificationUpdate(9)),
      expect: () => [isA<ProjectCommentsRepliesNotifError>()],
    );
  });

  blocTest<ProjectCommentsRepliesBloc, ProjectCommentsRepliesState>(
    'project-comments payload -> [DocLoaded]',
    build: () => ProjectCommentsRepliesBloc(api),
    act: (bloc) => bloc.add(const ProjectCommentsRepliesDocReceived([])),
    expect: () => [isA<ProjectCommentsRepliesDocLoaded>()],
  );
}
