import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/comments/adddoc_comments_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Add-Document-Comments submit flow after its move into
/// [AddDocCommentsBloc] (uploadAudio).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AudioReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<AddDocCommentsBloc, AddDocCommentsState>(
    'success -> [Loading, Success]',
    setUp: () {
      when(() => api.uploadAudio(any()))
          .thenAnswer((_) async => AudioRes(status: true, message: 'ok'));
    },
    build: () => AddDocCommentsBloc(api),
    act: (bloc) => bloc.add(AddDocCommentsSubmitted(AudioReq())),
    expect: () =>
        [isA<AddDocCommentsLoading>(), isA<AddDocCommentsSuccess>()],
  );

  blocTest<AddDocCommentsBloc, AddDocCommentsState>(
    'status false -> [Loading, Failure]',
    setUp: () {
      when(() => api.uploadAudio(any()))
          .thenAnswer((_) async => AudioRes(status: false, message: 'bad'));
    },
    build: () => AddDocCommentsBloc(api),
    act: (bloc) => bloc.add(AddDocCommentsSubmitted(AudioReq())),
    expect: () => [
      isA<AddDocCommentsLoading>(),
      isA<AddDocCommentsFailure>().having((s) => s.message, 'msg', 'bad'),
    ],
  );

  blocTest<AddDocCommentsBloc, AddDocCommentsState>(
    'throws -> [Loading, ErrorDismiss]',
    setUp: () {
      when(() => api.uploadAudio(any())).thenThrow(Exception('net'));
    },
    build: () => AddDocCommentsBloc(api),
    act: (bloc) => bloc.add(AddDocCommentsSubmitted(AudioReq())),
    expect: () =>
        [isA<AddDocCommentsLoading>(), isA<AddDocCommentsErrorDismiss>()],
  );
}
