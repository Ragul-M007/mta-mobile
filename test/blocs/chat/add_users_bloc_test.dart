import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/chat/add_users_bloc.dart';
import 'package:mta/models/Chat/AddRemoveUserListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/models/Chat/GroupCreationRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Add-Users REST + submit flows after their move into
/// [AddUsersBloc]. The socket is NOT initialized here (`_socket` stays null, so
/// its emits are null-safe no-ops); the live socket connect/join/add-users is
/// verified on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(GroupCreationReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  group('load (AddUsersLoadRequested)', () {
    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=true success -> [Loading, Loaded] via getUsers',
      setUp: () {
        when(() => api.getUsers(any(), any(), any())).thenAnswer(
          (_) async => AddUsersListRes(status: true, data: [AddUsersData()]),
        );
      },
      build: () => AddUsersBloc(api),
      act: (bloc) => bloc.add(const AddUsersLoadRequested(true, null, null, 5)),
      expect: () =>
          [isA<AddUsersLoading>(), isA<AddUsersLoaded>().having((s) => s.data.length, 'len', 1)],
      verify: (_) => verify(() => api.getUsers("team", 5, null)).called(1),
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=false success -> [Loading, Loaded] via getUnlinkedUsers',
      setUp: () {
        when(() => api.getUnlinkedUsers(any())).thenAnswer(
          (_) async => AddUsersListRes(status: true, data: [AddUsersData()]),
        );
      },
      build: () => AddUsersBloc(api),
      act: (bloc) => bloc.add(const AddUsersLoadRequested(false, 7, null, null)),
      expect: () => [isA<AddUsersLoading>(), isA<AddUsersLoaded>()],
      verify: (_) => verify(() => api.getUnlinkedUsers(7)).called(1),
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'status false -> [Loading, LoadFailed]',
      setUp: () {
        when(() => api.getUnlinkedUsers(any()))
            .thenAnswer((_) async => AddUsersListRes(status: false));
      },
      build: () => AddUsersBloc(api),
      act: (bloc) => bloc.add(const AddUsersLoadRequested(false, 7, null, null)),
      expect: () => [isA<AddUsersLoading>(), isA<AddUsersLoadFailed>()],
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'throws -> [Loading, LoadError]',
      setUp: () {
        when(() => api.getUnlinkedUsers(any())).thenThrow(Exception('net'));
      },
      build: () => AddUsersBloc(api),
      act: (bloc) => bloc.add(const AddUsersLoadRequested(false, 7, null, null)),
      expect: () => [isA<AddUsersLoading>(), isA<AddUsersLoadError>()],
    );
  });

  group('submit (AddUsersSubmitRequested)', () {
    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=true success -> [CreateLoading, CreatedNav]',
      setUp: () {
        when(() => api.createGroup(any())).thenAnswer(
          (_) async =>
              GroupCreationRes(status: true, message: 'made', data: Data(groupId: 9)),
        );
      },
      build: () => AddUsersBloc(api),
      act: (bloc) =>
          bloc.add(AddUsersSubmitRequested(true, GroupCreationReq(), [1, 2])),
      expect: () => [
        isA<AddUsersCreateLoading>(),
        isA<AddUsersCreatedNav>().having((s) => s.message, 'msg', 'made'),
      ],
      verify: (_) => verify(() => api.createGroup(any())).called(1),
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=true status false -> [CreateLoading, CreateFailed]',
      setUp: () {
        when(() => api.createGroup(any()))
            .thenAnswer((_) async => GroupCreationRes(status: false, message: 'no'));
      },
      build: () => AddUsersBloc(api),
      act: (bloc) =>
          bloc.add(AddUsersSubmitRequested(true, GroupCreationReq(), [1, 2])),
      expect: () => [
        isA<AddUsersCreateLoading>(),
        isA<AddUsersCreateFailed>().having((s) => s.message, 'msg', 'no'),
      ],
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=true throws -> [CreateLoading, CreateError]',
      setUp: () {
        when(() => api.createGroup(any())).thenThrow(Exception('x'));
      },
      build: () => AddUsersBloc(api),
      act: (bloc) =>
          bloc.add(AddUsersSubmitRequested(true, GroupCreationReq(), [1, 2])),
      expect: () =>
          [isA<AddUsersCreateLoading>(), isA<AddUsersCreateError>()],
    );

    blocTest<AddUsersBloc, AddUsersState>(
      'fromCreateGroup=false -> [AddedNav] (socket emit is a no-op in test)',
      build: () => AddUsersBloc(api),
      act: (bloc) => bloc.add(const AddUsersSubmitRequested(false, null, [1, 2])),
      expect: () => [isA<AddUsersAddedNav>()],
    );
  });
}
