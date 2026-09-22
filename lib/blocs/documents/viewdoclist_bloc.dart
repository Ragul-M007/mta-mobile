import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/FectchProjectDocReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';

part 'viewdoclist_event.dart';
part 'viewdoclist_state.dart';

/// BLoC for the View-Document-List screen (3 flows: updateNotification,
/// getDocs (branches on `Strings.category`), getUserCats (fetchUsers→fetchCats,
/// navigates to `/comments`)).
///
/// Behavior-preserving extraction following the established pattern: the BLoC
/// keeps the API calls, prefs reads, `Strings` writes and `print` logging; the
/// widget's listener performs the UI side effects (spinner, toast, navigation,
/// the `_docsList`/`_categorydocsList`/`_errText` setStates). States are
/// command-style (not Equatable).
class ViewDocListBloc extends Bloc<ViewDocListEvent, ViewDocListState> {
  final ApiService _api;

  ViewDocListBloc(this._api) : super(ViewDocInitial()) {
    on<ViewDocNotificationUpdate>(_onNotificationUpdate);
    on<ViewDocsRequested>(_onDocsRequested);
    on<ViewDocUserCatsRequested>(_onUserCatsRequested);
  }

  // Mirrors updateNotification()
  Future<void> _onNotificationUpdate(
      ViewDocNotificationUpdate event, Emitter<ViewDocListState> emit) async {
    try {
      final response =
          await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        // AppUtils.showToastError("Unable to update status");
      } else {
        emit(ViewDocNotifFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ViewDocNotifError());
    }
  }

  // Mirrors getDocs()
  Future<void> _onDocsRequested(
      ViewDocsRequested event, Emitter<ViewDocListState> emit) async {
    emit(ViewDocLoading());
    if (Strings.category == true) {
      print("Category");
      try {
        final value = await AppUtils.getIntPreferences('userId');
        final response = await _api.getCategoryDoc(
            Strings.selectedCategory[0].categoryId!,
            Strings.selectedProject[0].projectId!,
            value);
        print('DocsResponse status ${response.toJson()}');
        if (response.status!) {
          emit(ViewDocCategoryLoaded(response.data!));
        } else {
          emit(ViewDocEmpty());
        }
      } catch (onError) {
        print(onError.toString());
        emit(ViewDocErrorDismiss());
      }
    } else {
      try {
        final value = await AppUtils.getIntPreferences('userId');
        FetchProjectDocReq fetchProjectDocReq = FetchProjectDocReq();
        fetchProjectDocReq.projectId = Strings.selectedProject[0].projectId;
        final response =
            await _api.getProjectDoc(fetchProjectDocReq.projectId!, value);
        print('DocsResponse status ${response.toJson()}');
        if (response.status!) {
          emit(ViewDocProjectLoaded(response.data!));
        } else {
          emit(ViewDocEmpty());
        }
      } catch (onError) {
        print(onError.toString());
        emit(ViewDocErrorDismiss());
      }
    }
  }

  // Mirrors getUserCats()
  Future<void> _onUserCatsRequested(
      ViewDocUserCatsRequested event, Emitter<ViewDocListState> emit) async {
    emit(ViewDocLoading());
    try {
      final usersResp =
          await _api.fetchUsers(Strings.selectedProject[0].projectId!);
      if (usersResp.status!) {
        Strings.users = usersResp.data!;
        print("PRo id ${Strings.selectedProject[0].projectId!}");
        try {
          final catsResp =
              await _api.fetchCats(Strings.selectedProject[0].projectId!);
          if (catsResp.status!) {
            Strings.categories = catsResp.data!;
            emit(ViewDocCommentsNav());
          } else {
            emit(ViewDocCommentsNav());
            print('No categories');
          }
        } catch (onError) {
          print("Catched $onError");
          emit(ViewDocErrorDismiss());
        }
      } else {
        emit(ViewDocCommentsNav());
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ViewDocErrorDismiss());
    }
  }
}
