import 'package:equatable/equatable.dart';

interface class FeatureEntity {}

abstract class FeatureState extends Equatable implements FeatureEntity {}

abstract class SideEffect implements FeatureEntity {}

abstract class UiEvent {}
