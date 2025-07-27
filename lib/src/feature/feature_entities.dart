import 'package:equatable/equatable.dart';

interface class FeatureEntity {}

abstract class FeatureState extends Equatable implements FeatureEntity {}

class EmptyFeatureState extends FeatureState {
  @override
  List<Object?> get props => [];
}

abstract class SideEffect implements FeatureEntity {}

abstract class UiEvent {}
