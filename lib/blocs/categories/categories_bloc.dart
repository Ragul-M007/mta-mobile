import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchCategoryUsersRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'categories_event.dart';
part 'categories_state.dart';

/// BLoC for the Categories screen.
///
/// Behavior-preserving extraction of the former `_CategoriesContentState`
/// networking methods — `getUserCats()`, `getCategories()` and
/// `getAssignedUsers()`. The API calls and `print` logging are moved verbatim;
/// the spinner, `setState` of the screen's lists, toasts, and the pop/open of
/// the assigned-users dialog remain the widget's job, driven by the emitted
/// states via a stream subscription.
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final ApiService _api;

  CategoriesBloc(this._api) : super(const CategoriesInitial()) {
    on<CategoriesUsersRequested>(_onUsersRequested);
    on<CategoriesRequested>(_onCategoriesRequested);
    on<AssignedUsersRequested>(_onAssignedUsersRequested);
  }

  // Mirrors getUserCats()
  Future<void> _onUsersRequested(
      CategoriesUsersRequested event, Emitter<CategoriesState> emit) async {
    try {
      final response =
          await _api.fetchUsers(Strings.selectedProject[0].projectId!);
      if (response.status!) {
        emit(CategoriesUsersLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(CategoriesUsersError());
    }
  }

  // Mirrors getCategories()
  Future<void> _onCategoriesRequested(
      CategoriesRequested event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      final response =
          await _api.getCats(Strings.selectedProject[0].projectId!);
      print('categoiresResponse status ${response.toJson()}');
      if (response.status!) {
        emit(CategoriesLoaded(response.data!));
      } else {
        emit(CategoriesEmpty());
      }
    } catch (onError) {
      print(onError.toString());
      emit(CategoriesLoadError());
    }
  }

  // Mirrors getAssignedUsers()
  Future<void> _onAssignedUsersRequested(
      AssignedUsersRequested event, Emitter<CategoriesState> emit) async {
    try {
      final response = await _api.getCatUsers(
          Strings.selectedProject[0].projectId!, event.catID);
      if (response.status!) {
        emit(AssignedUsersLoaded(response.data!));
      } else {
        print('error');
        emit(AssignedUsersFailure(response.message ?? "Unknown Error"));
      }
    } catch (onError) {
      emit(AssignedUsersError(onError.toString()));
    }
  }
}
