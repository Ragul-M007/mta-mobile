import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/attendance/attendance_bloc.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/AddAttendanceRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for AttendanceBloc (mirrors getProjects / getAttendance /
/// checkInOut). Geolocation stays in the widget, so the check-in event here
/// just carries fixed location fields.
void main() {
  late MockApiService api;

  setUpAll(() {
    registerFallbackValue(AddAttendanceReq());
  });

  setUp(() {
    api = MockApiService();
    Strings.userID = 1078;
  });

  blocTest<AttendanceBloc, AttendanceState>(
    'projects success -> [ProjectsLoading, ProjectsLoaded]',
    build: () {
      when(() => api.projects(any())).thenAnswer(
        (_) async => DashboardRes(
          status: true,
          message: 'ok',
          data: [Data(projectId: 1, projectName: 'Skyline Residency Tower')],
        ),
      );
      return AttendanceBloc(api);
    },
    act: (bloc) => bloc.add(const AttendanceProjectsRequested()),
    expect: () => [
      isA<AttendanceProjectsLoading>(),
      isA<AttendanceProjectsLoaded>(),
    ],
  );

  blocTest<AttendanceBloc, AttendanceState>(
    'attendance records present -> [RecordsLoading, RecordsLoaded]',
    build: () {
      when(() => api.getAttendance(any(), any())).thenAnswer(
        (_) async => FetchAttendanceRes(
          status: true,
          radius: '50',
          data: [
            AttendanceData(
              checkType: 'IN',
              checkTime: '2026-09-15 09:00:00',
              locationName: 'Chennai Site',
            ),
          ],
        ),
      );
      return AttendanceBloc(api);
    },
    act: (bloc) => bloc.add(const AttendanceForDateRequested('15-09-2026')),
    expect: () => [
      isA<AttendanceRecordsLoading>(),
      isA<AttendanceRecordsLoaded>()
          .having((s) => s.records.length, 'records.length', 1),
    ],
  );

  blocTest<AttendanceBloc, AttendanceState>(
    'attendance empty -> [RecordsLoading, RecordsEmpty]',
    build: () {
      when(() => api.getAttendance(any(), any())).thenAnswer(
        (_) async => FetchAttendanceRes(status: true, radius: '50', data: []),
      );
      return AttendanceBloc(api);
    },
    act: (bloc) => bloc.add(const AttendanceForDateRequested('15-09-2026')),
    expect: () => [
      isA<AttendanceRecordsLoading>(),
      isA<AttendanceRecordsEmpty>(),
    ],
  );

  blocTest<AttendanceBloc, AttendanceState>(
    'check-in success -> [CheckLoading, CheckSuccess]',
    build: () {
      when(() => api.addAttendance(any())).thenAnswer(
        (_) async => AddAttendanceRes(status: true, message: 'Attendance added'),
      );
      return AttendanceBloc(api);
    },
    act: (bloc) => bloc.add(const AttendanceCheckInOutRequested(
      action: 'IN',
      lat: 13.0,
      long: 80.0,
      location: 'Chennai Site',
      projectId: 1,
    )),
    expect: () => [
      isA<AttendanceCheckLoading>(),
      isA<AttendanceCheckSuccess>()
          .having((s) => s.message, 'message', 'Attendance added'),
    ],
  );
}
