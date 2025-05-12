import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/settings_entities.dart';

class SettingsFeature extends Feature<SettingsEvent, SettingsState, SettingsSideEffect> {
  SettingsFeature() : super(initialState: SettingsState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(SettingsEvent event) async {
    if (event is LoadSettingsEvent) {
      await _loadSettings();
    } else if (event is ToggleDarkModeEvent) {
      _toggleDarkMode();
    } else if (event is ToggleNotificationsEvent) {
      _toggleNotifications();
    }
  }

  Future<void> _loadSettings() async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    emitState(state.copyWith(
      isLoading: false,
      darkMode: false,
      notificationsEnabled: true,
    ));
  }

  void _toggleDarkMode() {
    emitState(state.copyWith(
      darkMode: !state.darkMode,
    ));

    emitSifeEffect(SettingsUpdatedEffect(
      'Dark mode ${state.darkMode ? 'enabled' : 'disabled'}',
    ));
  }

  void _toggleNotifications() {
    emitState(state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    ));

    emitSifeEffect(SettingsUpdatedEffect(
      'Notifications ${state.notificationsEnabled ? 'enabled' : 'disabled'}',
    ));
  }
}
