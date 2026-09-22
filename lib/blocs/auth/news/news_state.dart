part of 'news_cubit.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

/// Show the loading spinner (EasyLoading), as getNewsFeeds() did.
class NewsLoading extends NewsState {
  const NewsLoading();
}

/// News loaded — the widget copies [news] into its `_newsLists`.
class NewsLoaded extends NewsState {
  final List<NewsResData> news;

  const NewsLoaded(this.news);

  @override
  List<Object?> get props => [news];
}

/// Fetch failed or returned status=false — nothing is rendered (matches the
/// original, which left `_newsLists` null and showed a SizedBox).
class NewsError extends NewsState {
  const NewsError();
}
