import 'package:equatable/equatable.dart';

interface class FeatureEntity {}

abstract class FeatureState extends Equatable implements FeatureEntity {
  const FeatureState();
}

class EmptyFeatureState extends FeatureState {
  const EmptyFeatureState();

  @override
  List<Object?> get props => [];
}

abstract class SideEffect implements FeatureEntity {}

abstract class UiEvent {}
