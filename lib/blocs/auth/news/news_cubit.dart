import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/network/ApiService.dart';

part 'news_state.dart';

/// Cubit for the login screen's News/Highlights fetch. Behavior-preserving
/// extraction of `getNewsFeeds()` — the list is emitted and the widget copies
/// it into its existing `_newsLists` field via a listener, so the News /
/// Highlights rendering is unchanged.
class NewsCubit extends Cubit<NewsState> {
  final ApiService _api;

  NewsCubit(this._api) : super(const NewsInitial());

  // Mirrors getNewsFeeds()
  Future<void> fetch() async {
    emit(const NewsLoading());
    try {
      final response = await _api.news();
      print('NewsResponse status ${response.toJson()}');
      if (response.status!) {
        emit(NewsLoaded(response.data!));
      } else {
        print('error');
        emit(const NewsError());
      }
    } catch (onError) {
      print(onError.toString());
      emit(const NewsError());
    }
  }
}
