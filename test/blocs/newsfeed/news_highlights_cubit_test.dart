import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/newsfeed/news_highlights_cubit.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for NewsHighlightsCubit (mirrors getNewsFeeds()).
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<NewsHighlightsCubit, NewsHighlightsState>(
    'fetch success -> [Loading, Loaded]',
    build: () {
      when(() => api.news()).thenAnswer(
        (_) async => NewsRes(status: true, data: [NewsResData()]),
      );
      return NewsHighlightsCubit(api);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      isA<NewsHighlightsLoading>(),
      isA<NewsHighlightsLoaded>().having((s) => s.news?.length, 'news.length', 1),
    ],
  );

  blocTest<NewsHighlightsCubit, NewsHighlightsState>(
    'fetch status false -> [Loading, Failure]',
    build: () {
      when(() => api.news()).thenAnswer(
        (_) async => NewsRes(status: false, message: 'No feed', data: []),
      );
      return NewsHighlightsCubit(api);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      isA<NewsHighlightsLoading>(),
      isA<NewsHighlightsFailure>().having((s) => s.message, 'message', 'No feed'),
    ],
  );

  blocTest<NewsHighlightsCubit, NewsHighlightsState>(
    'fetch throws -> [Loading, LoadError]',
    build: () {
      when(() => api.news()).thenThrow(Exception('network'));
      return NewsHighlightsCubit(api);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      isA<NewsHighlightsLoading>(),
      isA<NewsHighlightsLoadError>(),
    ],
  );
}
