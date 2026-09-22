import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/documents/adddoc_bloc.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/AddDocRes.dart';
import 'package:mta/models/DashboardRes.dart' as dash;
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/UserAccessreq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Add-Document flows after their move into [AddDocBloc]:
/// getUserCats (fetchUsers), submit (addDoc), UpdateRights (userAccess).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(AddDocReq());
    registerFallbackValue(UserAccessReq());
  });

  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.selectedProject = [dash.Data(projectId: 10)];
  });

  group('getUserCats (AddDocUsersRequested)', () {
    blocTest<AddDocBloc, AddDocState>(
      'success -> [UsersLoaded]',
      setUp: () {
        when(() => api.fetchUsers(any())).thenAnswer(
          (_) async => FetchMapedUsersRes(
              status: true, data: [FetchMapedUsersData()]),
        );
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(const AddDocUsersRequested()),
      expect: () =>
          [isA<AddDocUsersLoaded>().having((s) => s.data.length, 'len', 1)],
      verify: (_) => verify(() => api.fetchUsers(10)).called(1),
    );

    blocTest<AddDocBloc, AddDocState>(
      'status false -> [] (only prints error)',
      setUp: () {
        when(() => api.fetchUsers(any())).thenAnswer(
          (_) async => FetchMapedUsersRes(status: false, data: []),
        );
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(const AddDocUsersRequested()),
      expect: () => [],
    );

    blocTest<AddDocBloc, AddDocState>(
      'throws -> [ErrorDismiss]',
      setUp: () {
        when(() => api.fetchUsers(any())).thenThrow(Exception('network'));
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(const AddDocUsersRequested()),
      expect: () => [isA<AddDocErrorDismiss>()],
    );
  });

  group('submit (AddDocSubmitted)', () {
    blocTest<AddDocBloc, AddDocState>(
      'success -> [SubmitLoading, SubmitSuccess(docId)]',
      setUp: () {
        when(() => api.addDoc(any())).thenAnswer(
          (_) async => AddDocRes(
              status: true, message: 'ok', data: [Data(documentId: 7)]),
        );
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(AddDocSubmitted(AddDocReq())),
      expect: () => [
        isA<AddDocSubmitLoading>(),
        isA<AddDocSubmitSuccess>().having((s) => s.documentId, 'docId', 7),
      ],
    );

    blocTest<AddDocBloc, AddDocState>(
      'status false -> [SubmitLoading, Failure]',
      setUp: () {
        when(() => api.addDoc(any())).thenAnswer(
          (_) async => AddDocRes(status: false, message: 'bad'),
        );
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(AddDocSubmitted(AddDocReq())),
      expect: () => [
        isA<AddDocSubmitLoading>(),
        isA<AddDocFailure>().having((s) => s.message, 'msg', 'bad'),
      ],
    );

    blocTest<AddDocBloc, AddDocState>(
      'throws -> [SubmitLoading, ErrorDismiss]',
      setUp: () {
        when(() => api.addDoc(any())).thenThrow(Exception('network'));
      },
      build: () => AddDocBloc(api),
      act: (bloc) => bloc.add(AddDocSubmitted(AddDocReq())),
      expect: () => [isA<AddDocSubmitLoading>(), isA<AddDocErrorDismiss>()],
    );
  });

  group('UpdateRights (AddDocRightsRequested) — no state emitted', () {
    blocTest<AddDocBloc, AddDocState>(
      'success -> [] and calls userAccess',
      setUp: () {
        when(() => api.userAccess(any(), any()))
            .thenAnswer((_) async => LoginRes(status: true, message: 'ok'));
      },
      build: () => AddDocBloc(api),
      act: (bloc) =>
          bloc.add(AddDocRightsRequested('1,2', UserAccessReq())),
      expect: () => [],
      verify: (_) => verify(() => api.userAccess('1,2', any())).called(1),
    );

    blocTest<AddDocBloc, AddDocState>(
      'throws -> [] (only prints)',
      setUp: () {
        when(() => api.userAccess(any(), any())).thenThrow(Exception('x'));
      },
      build: () => AddDocBloc(api),
      act: (bloc) =>
          bloc.add(AddDocRightsRequested('1,2', UserAccessReq())),
      expect: () => [],
    );
  });
}
