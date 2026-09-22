import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/documents/viewdoclist_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/DashboardRes.dart' as dash;
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the View-Document-List flows after their move into
/// [ViewDocListBloc]: updateNotification, getDocs (category vs project branch),
/// getUserCats (fetchUsers → fetchCats → navigate).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService api;

  setUp(() {
    api = MockApiService();
    SharedPreferences.setMockInitialValues({'userId': 5});
    Strings.selectedProject = [dash.Data(projectId: 10)];
    Strings.selectedCategory = [FectchCatsData(categoryId: 3)];
    Strings.category = false;
    Strings.users = [];
    Strings.categories = [];
  });

  group('updateNotification (ViewDocNotificationUpdate)', () {
    blocTest<ViewDocListBloc, ViewDocListState>(
      'status true -> [] (no state)',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: true));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocNotificationUpdate(9)),
      expect: () => [],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'status false -> [NotifFailure]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocNotificationUpdate(9)),
      expect: () =>
          [isA<ViewDocNotifFailure>().having((s) => s.message, 'msg', 'no')],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'throws -> [NotifError]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenThrow(Exception('x'));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocNotificationUpdate(9)),
      expect: () => [isA<ViewDocNotifError>()],
    );
  });

  group('getDocs (ViewDocsRequested)', () {
    blocTest<ViewDocListBloc, ViewDocListState>(
      'category=true success -> [Loading, CategoryLoaded]',
      setUp: () {
        Strings.category = true;
        when(() => api.getCategoryDoc(any(), any(), any())).thenAnswer(
          (_) async => FetchCategoryDocRes(
              status: true, data: [FetchCategoryDoc()]),
        );
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocsRequested()),
      expect: () => [
        isA<ViewDocLoading>(),
        isA<ViewDocCategoryLoaded>().having((s) => s.data.length, 'len', 1),
      ],
      verify: (_) => verify(() => api.getCategoryDoc(3, 10, 5)).called(1),
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'category=true status false -> [Loading, Empty]',
      setUp: () {
        Strings.category = true;
        when(() => api.getCategoryDoc(any(), any(), any())).thenAnswer(
          (_) async => FetchCategoryDocRes(status: false),
        );
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocEmpty>()],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'category=false success -> [Loading, ProjectLoaded]',
      setUp: () {
        when(() => api.getProjectDoc(any(), any())).thenAnswer(
          (_) async =>
              FectchProjectDocRes(status: true, data: [ProjectDocData()]),
        );
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocsRequested()),
      expect: () => [
        isA<ViewDocLoading>(),
        isA<ViewDocProjectLoaded>().having((s) => s.data.length, 'len', 1),
      ],
      verify: (_) => verify(() => api.getProjectDoc(10, 5)).called(1),
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'category=false status false -> [Loading, Empty]',
      setUp: () {
        when(() => api.getProjectDoc(any(), any()))
            .thenAnswer((_) async => FectchProjectDocRes(status: false));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocEmpty>()],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'throws -> [Loading, ErrorDismiss]',
      setUp: () {
        when(() => api.getProjectDoc(any(), any())).thenThrow(Exception('net'));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocErrorDismiss>()],
    );
  });

  group('getUserCats (ViewDocUserCatsRequested)', () {
    blocTest<ViewDocListBloc, ViewDocListState>(
      'users ok + cats ok -> [Loading, CommentsNav] and writes Strings',
      setUp: () {
        when(() => api.fetchUsers(any())).thenAnswer((_) async =>
            FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
        when(() => api.fetchCats(any())).thenAnswer(
            (_) async => FetchMapedCatRes(status: true, data: [CatsData()]));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocUserCatsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocCommentsNav>()],
      verify: (_) {
        expect(Strings.users.length, 1);
        expect(Strings.categories.length, 1);
      },
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'users ok + cats status false -> [Loading, CommentsNav]',
      setUp: () {
        when(() => api.fetchUsers(any())).thenAnswer((_) async =>
            FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
        when(() => api.fetchCats(any()))
            .thenAnswer((_) async => FetchMapedCatRes(status: false));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocUserCatsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocCommentsNav>()],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'users ok + cats throws -> [Loading, ErrorDismiss]',
      setUp: () {
        when(() => api.fetchUsers(any())).thenAnswer((_) async =>
            FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
        when(() => api.fetchCats(any())).thenThrow(Exception('cats'));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocUserCatsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocErrorDismiss>()],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'users status false -> [Loading, CommentsNav]',
      setUp: () {
        when(() => api.fetchUsers(any()))
            .thenAnswer((_) async => FetchMapedUsersRes(status: false));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocUserCatsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocCommentsNav>()],
    );

    blocTest<ViewDocListBloc, ViewDocListState>(
      'users throws -> [Loading, ErrorDismiss]',
      setUp: () {
        when(() => api.fetchUsers(any())).thenThrow(Exception('users'));
      },
      build: () => ViewDocListBloc(api),
      act: (bloc) => bloc.add(const ViewDocUserCatsRequested()),
      expect: () => [isA<ViewDocLoading>(), isA<ViewDocErrorDismiss>()],
    );
  });
}
