import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/comments/comments_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ProjectDetails.dart' as pd;
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Comments REST + notification + doc-forwarding flows
/// after their move into [CommentsBloc]: fetchUsers, getProjectName, fetchCats,
/// removeComment, uploadAudio, updateNotificationStatus, and the
/// document-comments forwarding. The live socket connect/emit is verified
/// on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AudioReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<CommentsBloc, CommentsState>(
    'fetchUsers success -> [UserCatsLoaded]',
    setUp: () {
      when(() => api.fetchUsers(any())).thenAnswer((_) async =>
          FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
    },
    build: () => CommentsBloc(api),
    act: (bloc) => bloc.add(const CommentsUserCatsRequested(10)),
    expect: () => [isA<CommentsUserCatsLoaded>()],
  );

  blocTest<CommentsBloc, CommentsState>(
    'getProjectName success -> [ProjectLoaded]',
    setUp: () {
      when(() => api.getProjectName(any())).thenAnswer((_) async =>
          pd.ProjectDetailsRes(
              status: true, data: [pd.Data(projectName: 'Acme')]));
    },
    build: () => CommentsBloc(api),
    act: (bloc) => bloc.add(const CommentsProjectRequested(10)),
    expect: () =>
        [isA<CommentsProjectLoaded>().having((s) => s.name, 'name', 'Acme')],
  );

  group('fetchCats (CommentsCatsRequested)', () {
    blocTest<CommentsBloc, CommentsState>(
      'success -> [CatsLoaded]',
      setUp: () {
        when(() => api.fetchCats(any())).thenAnswer(
            (_) async => FetchMapedCatRes(status: true, data: [CatsData()]));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsCatsRequested(10)),
      expect: () => [isA<CommentsCatsLoaded>()],
    );

    blocTest<CommentsBloc, CommentsState>(
      'status false -> [Dismiss]',
      setUp: () {
        when(() => api.fetchCats(any()))
            .thenAnswer((_) async => FetchMapedCatRes(status: false));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsCatsRequested(10)),
      expect: () => [isA<CommentsDismiss>()],
    );
  });

  group('removeComment (CommentsRemoveRequested)', () {
    blocTest<CommentsBloc, CommentsState>(
      'success -> [RemoveLoading, RemoveOk]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: true));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsRemoveRequested(7)),
      expect: () => [isA<CommentsRemoveLoading>(), isA<CommentsRemoveOk>()],
    );

    blocTest<CommentsBloc, CommentsState>(
      'status false -> [RemoveLoading, RemoveFail]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: false));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsRemoveRequested(7)),
      expect: () => [isA<CommentsRemoveLoading>(), isA<CommentsRemoveFail>()],
    );

    blocTest<CommentsBloc, CommentsState>(
      'throws -> [RemoveLoading, RemoveError]',
      setUp: () {
        when(() => api.removeComment(any())).thenThrow(Exception('x'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsRemoveRequested(7)),
      expect: () => [isA<CommentsRemoveLoading>(), isA<CommentsRemoveError>()],
    );
  });

  group('uploadAudio (CommentsAudioRequested)', () {
    blocTest<CommentsBloc, CommentsState>(
      'success -> [AudioOk]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: true, message: 'ok'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(CommentsAudioRequested(AudioReq())),
      expect: () => [isA<CommentsAudioOk>()],
    );

    blocTest<CommentsBloc, CommentsState>(
      'status false -> [AudioFail]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: false, message: 'bad'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(CommentsAudioRequested(AudioReq())),
      expect: () =>
          [isA<CommentsAudioFail>().having((s) => s.message, 'msg', 'bad')],
    );

    blocTest<CommentsBloc, CommentsState>(
      'throws -> [AudioError]',
      setUp: () {
        when(() => api.uploadAudio(any())).thenThrow(Exception('x'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(CommentsAudioRequested(AudioReq())),
      expect: () => [isA<CommentsAudioError>()],
    );
  });

  group('updateNotification (CommentsNotificationUpdate)', () {
    blocTest<CommentsBloc, CommentsState>(
      'status false -> [NotifFailure]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsNotificationUpdate(9)),
      expect: () => [isA<CommentsNotifFailure>()],
    );

    blocTest<CommentsBloc, CommentsState>(
      'throws -> [NotifError]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenThrow(Exception('x'));
      },
      build: () => CommentsBloc(api),
      act: (bloc) => bloc.add(const CommentsNotificationUpdate(9)),
      expect: () => [isA<CommentsNotifError>()],
    );
  });

  blocTest<CommentsBloc, CommentsState>(
    'document-comments payload -> [DocLoaded]',
    build: () => CommentsBloc(api),
    act: (bloc) => bloc.add(const CommentsDocReceived([])),
    expect: () => [isA<CommentsDocLoaded>()],
  );
}
