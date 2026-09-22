import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/blocs/chat/remove_users_bloc.dart';
import 'package:mta/models/AddAttendanceRes.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Remove-Users-In-Group flows after their move into
/// [RemoveUsersBloc]: getUsersByGroupId (getChatUsers), removeUsersToGroupApiCall
/// (removeUsersintoGroup).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AddRemoveUserReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('load (RemoveUsersLoadRequested)', () {
    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'success -> [Loading, Loaded]',
      setUp: () {
        when(() => api.getChatUsers(any())).thenAnswer(
          (_) async =>
              GroupUsersRes(status: true, data: [GroupChatUsersData()]),
        );
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(const RemoveUsersLoadRequested(3)),
      expect: () => [
        isA<RemoveUsersLoading>(),
        isA<RemoveUsersLoaded>().having((s) => s.data.length, 'len', 1),
      ],
      verify: (_) => verify(() => api.getChatUsers(3)).called(1),
    );

    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'status false -> [Loading, LoadFailed]',
      setUp: () {
        when(() => api.getChatUsers(any()))
            .thenAnswer((_) async => GroupUsersRes(status: false));
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(const RemoveUsersLoadRequested(3)),
      expect: () =>
          [isA<RemoveUsersLoading>(), isA<RemoveUsersLoadFailed>()],
    );

    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'throws -> [Loading, LoadError]',
      setUp: () {
        when(() => api.getChatUsers(any())).thenThrow(Exception('net'));
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(const RemoveUsersLoadRequested(3)),
      expect: () =>
          [isA<RemoveUsersLoading>(), isA<RemoveUsersLoadError>()],
    );
  });

  group('submit (RemoveUsersSubmitted)', () {
    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'success -> [RemoveSuccess]',
      setUp: () {
        when(() => api.removeUsersintoGroup(any()))
            .thenAnswer((_) async => AddAttendanceRes(status: true, message: 'done'));
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(RemoveUsersSubmitted(AddRemoveUserReq())),
      expect: () => [
        isA<RemoveUsersRemoveSuccess>().having((s) => s.message, 'msg', 'done'),
      ],
    );

    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'status false -> [RemoveFailed]',
      setUp: () {
        when(() => api.removeUsersintoGroup(any()))
            .thenAnswer((_) async => AddAttendanceRes(status: false, message: 'no'));
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(RemoveUsersSubmitted(AddRemoveUserReq())),
      expect: () => [
        isA<RemoveUsersRemoveFailed>().having((s) => s.message, 'msg', 'no'),
      ],
    );

    blocTest<RemoveUsersBloc, RemoveUsersState>(
      'throws -> [RemoveError]',
      setUp: () {
        when(() => api.removeUsersintoGroup(any())).thenThrow(Exception('x'));
      },
      build: () => RemoveUsersBloc(api),
      act: (bloc) => bloc.add(RemoveUsersSubmitted(AddRemoveUserReq())),
      expect: () => [isA<RemoveUsersRemoveError>()],
    );
  });
}
