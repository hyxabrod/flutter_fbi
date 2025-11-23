import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi/flutter_fbi.dart' show featureTest;
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/settings_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/settings_entities.dart';

void main() {
  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
    'SettingsFeature load settings',
    build: () => SettingsFeature(),
    act: (f) => f.add(LoadSettingsEvent()),
    expect: () => <Object?>[],
  );

  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
    'SettingsFeature toggle dark mode emits state and side effect',
    build: () => SettingsFeature(),
    seed: () => const SettingsState(isLoading: false, darkMode: false, notificationsEnabled: true, error: null),
    act: (f) => f.add(ToggleDarkModeEvent()),
    expect: () => [isA<SettingsState>().having((s) => s.darkMode, 'darkMode', true)],
  );

  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
    'SettingsFeature toggle dark mode - side effects',
    build: () => SettingsFeature(),
    seed: () => const SettingsState(isLoading: false, darkMode: false, notificationsEnabled: true, error: null),
    act: (f) => f.add(ToggleDarkModeEvent()),
    expectSideEffects: () => [isA<SettingsUpdatedEffect>().having((e) => e.message, 'message', contains('Dark mode'))],
  );

  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
    'SettingsFeature toggle notifications emits state and side effect',
    build: () => SettingsFeature(),
    seed: () => const SettingsState(isLoading: false, darkMode: false, notificationsEnabled: true, error: null),
    act: (f) => f.add(ToggleNotificationsEvent()),
    expect: () => [isA<SettingsState>().having((s) => s.notificationsEnabled, 'notificationsEnabled', false)],
  );

  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
    'SettingsFeature toggle notifications - side effects',
    build: () => SettingsFeature(),
    seed: () => const SettingsState(isLoading: false, darkMode: false, notificationsEnabled: true, error: null),
    act: (f) => f.add(ToggleNotificationsEvent()),
    expectSideEffects: () =>
        [isA<SettingsUpdatedEffect>().having((e) => e.message, 'message', contains('Notifications'))],
  );
}
