import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/chat/chat_media_bloc.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/GroupDetailsRes.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/models/Chat/MediaDetailsRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Chat-Media flows after their move into [ChatMediaBloc]:
/// getDocumentDetails (getMediaDetails), getUsersByGroupId (getChatUsers),
/// getGroupData, deleteGroup.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('getDocumentDetails (ChatMediaDocsRequested)', () {
    blocTest<ChatMediaBloc, ChatMediaState>(
      'image success -> [DocsLoaded(image)]',
      setUp: () {
        when(() => api.getMediaDetails(any(), any())).thenAnswer(
          (_) async => MediaDetailsRes(status: true, data: [MediaData()]),
        );
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDocsRequested(3, "image")),
      expect: () => [
        isA<ChatMediaDocsLoaded>()
            .having((s) => s.type, 'type', 'image')
            .having((s) => s.data.length, 'len', 1),
      ],
      verify: (_) => verify(() => api.getMediaDetails(3, "image")).called(1),
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'status false -> [] (print only)',
      setUp: () {
        when(() => api.getMediaDetails(any(), any()))
            .thenAnswer((_) async => MediaDetailsRes(status: false));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDocsRequested(3, "video")),
      expect: () => [],
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'throws -> [ErrorDismiss]',
      setUp: () {
        when(() => api.getMediaDetails(any(), any()))
            .thenThrow(Exception('net'));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDocsRequested(3, "document")),
      expect: () => [isA<ChatMediaErrorDismiss>()],
    );
  });

  group('getUsersByGroupId (ChatMediaUsersRequested)', () {
    blocTest<ChatMediaBloc, ChatMediaState>(
      'success -> [UsersLoaded]',
      setUp: () {
        when(() => api.getChatUsers(any())).thenAnswer((_) async =>
            GroupUsersRes(status: true, data: [GroupChatUsersData()]));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaUsersRequested(3)),
      expect: () =>
          [isA<ChatMediaUsersLoaded>().having((s) => s.data.length, 'len', 1)],
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'throws -> [ErrorDismiss]',
      setUp: () {
        when(() => api.getChatUsers(any())).thenThrow(Exception('net'));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaUsersRequested(3)),
      expect: () => [isA<ChatMediaErrorDismiss>()],
    );
  });

  group('getGroupData (ChatMediaGroupDataRequested)', () {
    blocTest<ChatMediaBloc, ChatMediaState>(
      'success -> [GroupDataLoaded(groupCreatedBy)]',
      setUp: () {
        when(() => api.getGroupData(any())).thenAnswer((_) async =>
            GroupDetailsRes(status: true, data: Data(groupCreatedBy: 42)));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaGroupDataRequested(3)),
      expect: () => [
        isA<ChatMediaGroupDataLoaded>()
            .having((s) => s.groupCreatedBy, 'groupCreatedBy', 42),
      ],
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'throws -> [ErrorDismiss]',
      setUp: () {
        when(() => api.getGroupData(any())).thenThrow(Exception('net'));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaGroupDataRequested(3)),
      expect: () => [isA<ChatMediaErrorDismiss>()],
    );
  });

  group('deleteGroup (ChatMediaDeleteGroupRequested)', () {
    blocTest<ChatMediaBloc, ChatMediaState>(
      'success -> [DeleteLoading, DeleteSuccess(comment)]',
      setUp: () {
        when(() => api.deleteGroup(any()))
            .thenAnswer((_) async => CommentsRes(status: true, comment: 'gone'));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDeleteGroupRequested(3)),
      expect: () => [
        isA<ChatMediaDeleteLoading>(),
        isA<ChatMediaDeleteSuccess>().having((s) => s.comment, 'comment', 'gone'),
      ],
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'status false -> [DeleteLoading, DeleteFailed]',
      setUp: () {
        when(() => api.deleteGroup(any()))
            .thenAnswer((_) async => CommentsRes(status: false));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDeleteGroupRequested(3)),
      expect: () =>
          [isA<ChatMediaDeleteLoading>(), isA<ChatMediaDeleteFailed>()],
    );

    blocTest<ChatMediaBloc, ChatMediaState>(
      'throws -> [DeleteLoading, DeleteFailed]',
      setUp: () {
        when(() => api.deleteGroup(any())).thenThrow(Exception('net'));
      },
      build: () => ChatMediaBloc(api),
      act: (bloc) => bloc.add(const ChatMediaDeleteGroupRequested(3)),
      expect: () =>
          [isA<ChatMediaDeleteLoading>(), isA<ChatMediaDeleteFailed>()],
    );
  });
}
