import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/categories/categories_bloc.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchCategoryUsersRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for CategoriesBloc (mirrors getUserCats / getCategories /
/// getAssignedUsers). A selected project is required (the BLoC reads
/// `Strings.selectedProject[0].projectId`).
void main() {
  late MockApiService api;

  setUp(() {
    api = MockApiService();
    Strings.selectedProject = [Data(projectId: 1, projectName: 'P1')];
  });

  blocTest<CategoriesBloc, CategoriesState>(
    'users success -> [CategoriesUsersLoaded]',
    build: () {
      when(() => api.fetchUsers(any())).thenAnswer(
        (_) async =>
            FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]),
      );
      return CategoriesBloc(api);
    },
    act: (bloc) => bloc.add(const CategoriesUsersRequested()),
    expect: () => [isA<CategoriesUsersLoaded>()],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'categories success -> [CategoriesLoading, CategoriesLoaded]',
    build: () {
      when(() => api.getCats(any())).thenAnswer(
        (_) async => FectchCatsRes(status: true, data: [FectchCatsData()]),
      );
      return CategoriesBloc(api);
    },
    act: (bloc) => bloc.add(const CategoriesRequested()),
    expect: () => [isA<CategoriesLoading>(), isA<CategoriesLoaded>()],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'categories empty (status false) -> [CategoriesLoading, CategoriesEmpty]',
    build: () {
      when(() => api.getCats(any())).thenAnswer(
        (_) async => FectchCatsRes(status: false, message: 'none', data: []),
      );
      return CategoriesBloc(api);
    },
    act: (bloc) => bloc.add(const CategoriesRequested()),
    expect: () => [isA<CategoriesLoading>(), isA<CategoriesEmpty>()],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'assigned users success -> [AssignedUsersLoaded]',
    build: () {
      when(() => api.getCatUsers(any(), any())).thenAnswer(
        (_) async =>
            FetchCategoryUsersRes(status: true, data: [CategoryUsersData()]),
      );
      return CategoriesBloc(api);
    },
    act: (bloc) => bloc.add(const AssignedUsersRequested(5)),
    expect: () => [isA<AssignedUsersLoaded>()],
  );
}
