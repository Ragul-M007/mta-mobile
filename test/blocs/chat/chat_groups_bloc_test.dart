import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/chat/chat_groups_bloc.dart';
import 'package:mta/models/AccessDetailsRes.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Chat-Groups REST flows after their move into
/// [ChatGroupsBloc]: fetchChatCreateAcess (getAccessDetails), createGroup
/// (checkGroupName). The socket `all-groups` stream is verified on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('access (ChatGroupsAccessRequested)', () {
    blocTest<ChatGroupsBloc, ChatGroupsState>(
      'success -> [AccessLoaded]',
      setUp: () {
        when(() => api.getAccessDetails()).thenAnswer(
          (_) async =>
              AccessDetailsRes(status: true, data: Data(groupCreateAccess: 1)),
        );
      },
      build: () => ChatGroupsBloc(api),
      act: (bloc) => bloc.add(const ChatGroupsAccessRequested()),
      expect: () => [
        isA<ChatGroupsAccessLoaded>()
            .having((s) => s.groupCreateAccess, 'access', 1),
      ],
    );

    blocTest<ChatGroupsBloc, ChatGroupsState>(
      'throws -> [] (print only)',
      setUp: () {
        when(() => api.getAccessDetails()).thenThrow(Exception('net'));
      },
      build: () => ChatGroupsBloc(api),
      act: (bloc) => bloc.add(const ChatGroupsAccessRequested()),
      expect: () => [],
    );
  });

  group('createGroup (ChatGroupsCreateRequested)', () {
    blocTest<ChatGroupsBloc, ChatGroupsState>(
      'name ok -> [CreateLoading, CreateOk]',
      setUp: () {
        when(() => api.checkGroupName(any()))
            .thenAnswer((_) async => CommonRes(status: true));
      },
      build: () => ChatGroupsBloc(api),
      act: (bloc) =>
          bloc.add(ChatGroupsCreateRequested(GroupCreationReq(), "Team A")),
      expect: () =>
          [isA<ChatGroupsCreateLoading>(), isA<ChatGroupsCreateOk>()],
      verify: (_) => verify(() => api.checkGroupName("Team A")).called(1),
    );

    blocTest<ChatGroupsBloc, ChatGroupsState>(
      'name taken -> [CreateLoading, CreateFailed]',
      setUp: () {
        when(() => api.checkGroupName(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'taken'));
      },
      build: () => ChatGroupsBloc(api),
      act: (bloc) =>
          bloc.add(ChatGroupsCreateRequested(GroupCreationReq(), "Team A")),
      expect: () => [
        isA<ChatGroupsCreateLoading>(),
        isA<ChatGroupsCreateFailed>().having((s) => s.message, 'msg', 'taken'),
      ],
    );

    blocTest<ChatGroupsBloc, ChatGroupsState>(
      'throws -> [CreateLoading, CreateError]',
      setUp: () {
        when(() => api.checkGroupName(any())).thenThrow(Exception('x'));
      },
      build: () => ChatGroupsBloc(api),
      act: (bloc) =>
          bloc.add(ChatGroupsCreateRequested(GroupCreationReq(), "Team A")),
      expect: () =>
          [isA<ChatGroupsCreateLoading>(), isA<ChatGroupsCreateError>()],
    );
  });
}
