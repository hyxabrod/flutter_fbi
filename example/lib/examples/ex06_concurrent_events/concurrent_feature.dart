import 'package:flutter_fbi/flutter_fbi.dart';
import 'concurrent_entities.dart';

class ConcurrentFeature extends Feature<ConcurrentEvent, ConcurrentState, ConcurrentFx> {
  ConcurrentFeature() : super(initialState: const ConcurrentState(0)) {
    onEvent((event) async {
      if (event is SlowIncEvent) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        emitState(ConcurrentState(state.value + 1));
        emitSideEffect(ConcurrentFx('slow-inc-done'));
      } else if (event is FastPingEvent) {
        emitSideEffect(ConcurrentFx('fast'));
      }
    });
  }
}
