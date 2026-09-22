import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/contactus/contactus_bloc.dart';
import 'package:mta/models/BackLinkRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for ContactusBloc (mirrors getSocialsMediaLinks()).
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<ContactusBloc, ContactusState>(
    'success -> [Loading, Loaded]',
    build: () {
      when(() => api.getSocialsBackLink()).thenAnswer(
        (_) async => BackLinkRes(
          status: true,
          data: [Data(instagramLink: 'i', twitterLink: 't', linkedin: 'l')],
        ),
      );
      return ContactusBloc(api);
    },
    act: (bloc) => bloc.add(const SocialLinksRequested()),
    expect: () => [
      isA<SocialLinksLoading>(),
      isA<SocialLinksLoaded>().having((s) => s.data.length, 'len', 1),
    ],
  );

  blocTest<ContactusBloc, ContactusState>(
    'throws -> [Loading, Error]',
    build: () {
      when(() => api.getSocialsBackLink()).thenThrow(Exception('network'));
      return ContactusBloc(api);
    },
    act: (bloc) => bloc.add(const SocialLinksRequested()),
    expect: () => [isA<SocialLinksLoading>(), isA<SocialLinksError>()],
  );
}
