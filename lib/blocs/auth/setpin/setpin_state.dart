part of 'setpin_bloc.dart';

/// Where a successful authentication should navigate to — mirrors the
/// original `signinafterpin()` navigation branches exactly.
enum SetpinDestination { attendance, projects, teamsDashboard }

abstract class SetpinState extends Equatable {
  const SetpinState();

  @override
  List<Object?> get props => [];
}

class SetpinInitial extends SetpinState {
  const SetpinInitial();
}

/// Show the loading spinner (EasyLoading).
class SetpinLoading extends SetpinState {
  const SetpinLoading();
}

/// A handled failure (response.status == false) — show [message] as a toast.
class SetpinFailure extends SetpinState {
  final String message;

  const SetpinFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// An unexpected error (the original catchError path) — dismiss the loader
/// only, with no toast (matches the old behavior, which just printed).
class SetpinError extends SetpinState {
  final String error;

  const SetpinError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Auth succeeded — navigate to [destination].
class SetpinAuthenticated extends SetpinState {
  final SetpinDestination destination;

  const SetpinAuthenticated(this.destination);

  @override
  List<Object?> get props => [destination];
}
