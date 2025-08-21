import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'concurrent_entities.dart';
import 'concurrent_feature.dart';

class ConcurrentBinder
    extends FeatureBinder<ConcurrentEvent, ConcurrentState, ConcurrentUiState, ConcurrentSideEffect> {
  ConcurrentBinder({required BuildContext context})
      : super(
          context: context,
          feature: ConcurrentFeature(),
          uiStatePreprocessor: () => const ConcurrentUiState(0, '0'),
        ) {
    bindSideEffect((fx) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fx.msg)),
      );
    });
  }

  void slowInc() => feature.add(SlowIncEvent());
  void fastPing() => feature.add(FastPingEvent(), sync: false);

  @override
  ConcurrentUiState uiStateTransformer(ConcurrentState featureState) {
    return ConcurrentUiState(
      featureState.value,
      featureState.value.toString(),
    );
  }
}

class ConcurrentUiState extends BinderState {
  final int value;
  final String label;
  const ConcurrentUiState(this.value, this.label);
  @override
  List<Object?> get props => [value, label];
}
