part of 'setpin_bloc.dart';

abstract class SetpinEvent extends Equatable {
  const SetpinEvent();

  @override
  List<Object?> get props => [];
}

/// The user tapped SUBMIT with a completed 4-digit pin.
class SetpinSubmitted extends SetpinEvent {
  final String pin;

  const SetpinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}
