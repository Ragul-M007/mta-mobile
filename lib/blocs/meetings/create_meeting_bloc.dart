import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/IntegratedMeetingsData.dart';
import 'package:mta/network/ApiService.dart';

part 'create_meeting_event.dart';
part 'create_meeting_state.dart';

/// BLoC for the Create-Meeting form's initial data load.
///
/// Behavior-preserving extraction of the `getIntegratedMeetings()` →
/// `getTeams()` → `getProjects()` chain. Each step's fetch and `print` logging
/// move verbatim; the widget sets `integratedMeetingsList`, `teamLists` and
/// `projectsList` from the emitted states (only the final projects step calls
/// setState, exactly like the original). A network error at any step stops the
/// chain (the original's catchError did not call the next step). The idempotency
/// guards (`if (teamLists.isEmpty)` / `if (projectsList.isEmpty)`) are dropped —
/// they are always true on the single initState load.
class CreateMeetingBloc extends Bloc<CreateMeetingEvent, CreateMeetingState> {
  final ApiService _api;

  CreateMeetingBloc(this._api) : super(const CreateMeetingInitial()) {
    on<CreateMeetingDataRequested>(_onRequested);
  }

  Future<void> _onRequested(
      CreateMeetingDataRequested event, Emitter<CreateMeetingState> emit) async {
    // getIntegratedMeetings()
    try {
      final r1 = await _api.fetchIntegratedMeetings();
      if (r1.status!) emit(CreateMeetingIntegratedLoaded(r1.data!));
    } catch (onError) {
      print(onError.toString());
      return; // catchError did not call getTeams()
    }
    // getTeams()
    try {
      final r2 = await _api.fetchAllTeams();
      if (r2.status!) emit(CreateMeetingTeamsLoaded(r2.data!));
    } catch (onError) {
      print(onError.toString());
      return; // catchError did not call getProjects()
    }
    // getProjects()
    try {
      final r3 = await _api.fetchAllProjects();
      if (r3.status!) emit(CreateMeetingProjectsLoaded(r3.data!));
    } catch (onError) {
      print(onError.toString());
    }
  }
}
