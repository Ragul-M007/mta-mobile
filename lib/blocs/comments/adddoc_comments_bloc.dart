import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/network/ApiService.dart';

part 'adddoc_comments_event.dart';
part 'adddoc_comments_state.dart';

/// BLoC for the Add-Document-Comments (Add Videos/images) screen — one flow:
/// submit() → uploadAudio.
///
/// Behavior-preserving extraction: the BLoC keeps the API call and `print`
/// logging; the widget's listener performs the UI side effects (spinner, toast,
/// the 4-way navigation branch on `Strings.documentUploadfromProject` +
/// `fromReplies`). States are command-style (not Equatable).
class AddDocCommentsBloc
    extends Bloc<AddDocCommentsEvent, AddDocCommentsState> {
  final ApiService _api;

  AddDocCommentsBloc(this._api) : super(AddDocCommentsInitial()) {
    on<AddDocCommentsSubmitted>(_onSubmitted);
  }

  // Mirrors the api.uploadAudio(...) portion of submit()
  Future<void> _onSubmitted(
      AddDocCommentsSubmitted event, Emitter<AddDocCommentsState> emit) async {
    emit(AddDocCommentsLoading());
    try {
      final response = await _api.uploadAudio(event.req);
      if (response.status!) {
        emit(AddDocCommentsSuccess());
      } else {
        emit(AddDocCommentsFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(AddDocCommentsErrorDismiss());
    }
  }
}
