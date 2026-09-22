import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/CurrentProjectReq.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

/// BLoC for the Attendance screen.
///
/// Behavior-preserving extraction of the former `_AttendanceContentState`
/// networking methods — `getProjects()`, `updateCurrentProject()`,
/// `getAttendance()` and `checkInOut()`. The API calls, `Strings` writes and
/// `print` logging are moved verbatim; the spinner, toasts, `setState` of the
/// screen's globals/fields, `formatAttendanceData()` and the grid/list-aware
/// list refresh remain the widget's job, driven by the emitted states via a
/// `BlocListener`. Geolocation (`getUserLocation`/`getGeocode`) stays in the
/// widget — it both mutates the top-level `lat`/`long`/`distance`/`location`
/// globals and is awaited inline by the check flow, so moving it would be a
/// rewrite rather than a move.
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ApiService _api;

  AttendanceBloc(this._api) : super(const AttendanceInitial()) {
    on<AttendanceProjectsRequested>((event, emit) => _getProjects(emit));
    on<AttendanceCurrentProjectUpdated>(_onCurrentProjectUpdated);
    on<AttendanceForDateRequested>(_onForDateRequested);
    on<AttendanceCheckInOutRequested>(_onCheckInOut);
  }

  // Mirrors _AttendanceContentState.getProjects()
  Future<void> _getProjects(Emitter<AttendanceState> emit) async {
    emit(AttendanceProjectsLoading());
    try {
      final response = await _api.projects(Strings.userID!);
      if (response.status!) {
        print("messagee from api ${response.message}");
        emit(AttendanceProjectsLoaded(response.data, response.token));
      } else {
        emit(AttendanceProjectsFailure(response.message ?? "Error"));
      }
    } catch (onError) {
      print("caddd");
      print(onError.toString());
      emit(AttendanceProjectsError());
    }
  }

  // Mirrors _AttendanceContentState.updateCurrentProject()
  Future<void> _onCurrentProjectUpdated(AttendanceCurrentProjectUpdated event,
      Emitter<AttendanceState> emit) async {
    emit(AttendanceProjectsLoading());
    print("qw11");
    CurrentProjectReq req = CurrentProjectReq();
    req.userId = Strings.userID;
    req.projectId = event.projectId;
    try {
      final response = await _api.setCurrentProject(req);
      if (response.status!) {
        await _getProjects(emit);
      } else {
        emit(AttendanceCurrentProjectFailure(response.message ?? "Error"));
      }
    } catch (onError) {
      print(onError.toString());
      emit(AttendanceProjectsError());
    }
  }

  // Mirrors _AttendanceContentState.getAttendance()
  Future<void> _onForDateRequested(
      AttendanceForDateRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceRecordsLoading());
    try {
      final response = await _api.getAttendance(Strings.userID!, event.date);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        // to handle the check in distance
        Strings.checkInRadius = int.tryParse(response.radius ?? "50")!;
        if (response.data!.length > 0) {
          print("response fetched");
          emit(AttendanceRecordsLoaded(response.data!));
        } else {
          emit(AttendanceRecordsEmpty());
        }
      } else {
        emit(AttendanceRecordsFailure(response.message!));
      }
    } catch (onError) {
      print("catch");
      print("error on catch ${onError.toString()}");
      emit(AttendanceRecordsError());
    }
  }

  // Mirrors _AttendanceContentState.checkInOut()
  Future<void> _onCheckInOut(AttendanceCheckInOutRequested event,
      Emitter<AttendanceState> emit) async {
    emit(AttendanceCheckLoading());
    AddAttendanceReq req = AddAttendanceReq();
    //req.checkTime = DateFormat().add_jm().format(DateTime.now()).toString();
    req.checkTime = DateTime.now().toString();
    req.checkType = event.action;
    req.latLng = event.lat.toString() + "," + event.long.toString();
    req.locationName = event.location;
    req.projectId = event.projectId;
    print("payload ${jsonEncode(req)}");
    try {
      final response = await _api.addAttendance(req);
      print("checking out");
      print('Response status ${response.toJson()}');
      if (response.status!) {
        emit(AttendanceCheckSuccess(response.message!));
      } else {
        emit(AttendanceCheckFailure(response.message!));
      }
    } catch (onError) {
      print("incatch");
      print(onError.toString());
      emit(AttendanceCheckError());
    }
  }
}
