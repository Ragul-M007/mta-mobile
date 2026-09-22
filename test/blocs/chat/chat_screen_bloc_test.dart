import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/chat/chat_screen_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/GroupReq.dart';
import 'package:mta/models/GroupRes.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Chat-screen REST + data-forwarding flows after their
/// move into [ChatScreenBloc]: getChatUsers, deleteMessage, fetchGroupList,
/// getReadedUsers, and the group-messages/group-users-list forwarding. The
/// socket connect/emit and the Dio upload are verified on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(GroupReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('getChatUsers (ChatUsersRequested)', () {
    blocTest<ChatScreenBloc, ChatScreenState>(
      'success -> [UsersLoaded]',
      setUp: () {
        when(() => api.getChatUsers(any())).thenAnswer((_) async =>
            GroupUsersRes(status: true, data: [GroupChatUsersData()]));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatUsersRequested(3)),
      expect: () =>
          [isA<ChatUsersLoaded>().having((s) => s.data.length, 'len', 1)],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'status false -> [] (print only)',
      setUp: () {
        when(() => api.getChatUsers(any()))
            .thenAnswer((_) async => GroupUsersRes(status: false));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatUsersRequested(3)),
      expect: () => [],
    );
  });

  group('deleteMessage (ChatDeleteRequested)', () {
    blocTest<ChatScreenBloc, ChatScreenState>(
      'success -> [DeleteOk]',
      setUp: () {
        when(() => api.deleteMessage(any(), any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'gone'));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatDeleteRequested(1, 2)),
      expect: () =>
          [isA<ChatDeleteOk>().having((s) => s.message, 'msg', 'gone')],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'status false -> [DeleteFail]',
      setUp: () {
        when(() => api.deleteMessage(any(), any()))
            .thenAnswer((_) async => CommonRes(status: false));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatDeleteRequested(1, 2)),
      expect: () => [isA<ChatDeleteFail>()],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'throws -> [DeleteError]',
      setUp: () {
        when(() => api.deleteMessage(any(), any())).thenThrow(Exception('x'));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatDeleteRequested(1, 2)),
      expect: () => [isA<ChatDeleteError>()],
    );
  });

  group('fetchGroupList (ChatForwardListRequested)', () {
    blocTest<ChatScreenBloc, ChatScreenState>(
      'success -> [ForwardListLoading, ForwardListLoaded]',
      setUp: () {
        when(() => api.fetchGroupList(any()))
            .thenAnswer((_) async => GroupRes(status: true, data: [Data()]));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(ChatForwardListRequested(GroupReq())),
      expect: () =>
          [isA<ChatForwardListLoading>(), isA<ChatForwardListLoaded>()],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'status false -> [ForwardListLoading, ForwardListFailed]',
      setUp: () {
        when(() => api.fetchGroupList(any()))
            .thenAnswer((_) async => GroupRes(status: false, message: 'no'));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(ChatForwardListRequested(GroupReq())),
      expect: () => [
        isA<ChatForwardListLoading>(),
        isA<ChatForwardListFailed>().having((s) => s.message, 'msg', 'no'),
      ],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'throws -> [ForwardListLoading, ForwardListError]',
      setUp: () {
        when(() => api.fetchGroupList(any())).thenThrow(Exception('x'));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(ChatForwardListRequested(GroupReq())),
      expect: () =>
          [isA<ChatForwardListLoading>(), isA<ChatForwardListError>()],
    );
  });

  group('getReadedUsers (ChatReadUsersRequested)', () {
    blocTest<ChatScreenBloc, ChatScreenState>(
      'success -> [ReadUsersLoaded]',
      setUp: () {
        when(() => api.getReadedUsers(any())).thenAnswer((_) async =>
            FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatReadUsersRequested(5)),
      expect: () =>
          [isA<ChatReadUsersLoaded>().having((s) => s.data.length, 'len', 1)],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'status false -> [ReadUsersFailed]',
      setUp: () {
        when(() => api.getReadedUsers(any()))
            .thenAnswer((_) async => FetchMapedUsersRes(status: false));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatReadUsersRequested(5)),
      expect: () => [isA<ChatReadUsersFailed>()],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'throws -> [ReadUsersError]',
      setUp: () {
        when(() => api.getReadedUsers(any())).thenThrow(Exception('x'));
      },
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatReadUsersRequested(5)),
      expect: () => [isA<ChatReadUsersError>()],
    );
  });

  group('socket payload forwarding', () {
    blocTest<ChatScreenBloc, ChatScreenState>(
      'group-messages -> [ChatGroupMessagesSocket]',
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatGroupMessagesReceived([])),
      expect: () => [isA<ChatGroupMessagesSocket>()],
    );

    blocTest<ChatScreenBloc, ChatScreenState>(
      'group-users-list -> [ChatGroupUsersSocket]',
      build: () => ChatScreenBloc(api),
      act: (bloc) => bloc.add(const ChatGroupUsersReceived([])),
      expect: () => [isA<ChatGroupUsersSocket>()],
    );
  });
}
