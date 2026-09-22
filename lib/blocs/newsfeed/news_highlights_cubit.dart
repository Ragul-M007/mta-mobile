import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/network/ApiService.dart';

part 'news_highlights_state.dart';

/// Cubit for the standalone News & Highlights screen.
///
/// Behavior-preserving extraction of `_NewshighlightsContentState.getNewsFeeds()`.
/// The API call and `print` logging move verbatim; the spinner, `setState` of
/// `_newsLists` and the error toast remain the widget's job via a listener.
/// This is separate from the login screen's [NewsCubit] because that one prints
/// on failure whereas this screen shows an error toast.
class NewsHighlightsCubit extends Cubit<NewsHighlightsState> {
  final ApiService _api;

  NewsHighlightsCubit(this._api) : super(const NewsHighlightsInitial());

  // Mirrors getNewsFeeds()
  Future<void> fetch() async {
    emit(const NewsHighlightsLoading());
    try {
      final response = await _api.news();
      print('NewsResponse status ${response.toJson()}');
      if (response.status!) {
        emit(NewsHighlightsLoaded(response.data));
      } else {
        emit(NewsHighlightsFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(const NewsHighlightsLoadError());
    }
  }
}
