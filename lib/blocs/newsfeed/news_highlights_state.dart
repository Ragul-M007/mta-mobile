part of 'news_highlights_cubit.dart';

abstract class NewsHighlightsState extends Equatable {
  const NewsHighlightsState();

  @override
  List<Object?> get props => [];
}

class NewsHighlightsInitial extends NewsHighlightsState {
  const NewsHighlightsInitial();
}

/// Show the loading spinner (getNewsFeeds start).
class NewsHighlightsLoading extends NewsHighlightsState {
  const NewsHighlightsLoading();
}

/// News fetched — dismiss the spinner and set `_newsLists` to [news].
class NewsHighlightsLoaded extends NewsHighlightsState {
  final List<NewsResData>? news;

  const NewsHighlightsLoaded(this.news);

  @override
  List<Object?> get props => [news];
}

/// `status == false` — dismiss the spinner and show [message] as an error toast.
class NewsHighlightsFailure extends NewsHighlightsState {
  final String message;

  const NewsHighlightsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Unexpected error (the old `catchError` path) — dismiss the spinner only.
class NewsHighlightsLoadError extends NewsHighlightsState {
  const NewsHighlightsLoadError();
}
