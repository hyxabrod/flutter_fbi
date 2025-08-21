import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/user_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/settings_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/user_entities.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/settings_entities.dart';

void main() {
  testWidgets('UserFeature and SettingsFeature load and emit side effects', (tester) async {
    // Test UserFeature load
  featureTest<UserEvent, UserState, UserSideEffect>(
      'user load',
      build: () => UserFeature(),
      act: (f) => f.add(LoadUserEvent()),
      expect: () => [
    const UserState(isLoading: true),
    const UserState(isLoading: false, name: 'John Doe', email: 'john.doe@example.com'),
      ],
    );

    // Test SettingsFeature toggles
  featureTest<SettingsEvent, SettingsState, SettingsSideEffect>(
      'settings toggle',
      build: () => SettingsFeature(),
      act: (f) => f.add(ToggleDarkModeEvent()),
      expect: () => [
    const SettingsState(darkMode: true, notificationsEnabled: true),
      ],
      expectSideEffects: () => [
    const SettingsUpdatedEffect('Dark mode enabled'),
      ],
    );
  });
}
