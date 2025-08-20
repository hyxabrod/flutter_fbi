import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/settings_entities.dart';

class SettingsFeature extends Feature<SettingsEvent, SettingsState, SettingsSideEffect> {
  SettingsFeature() : super(initialState: const SettingsState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(SettingsEvent event) async {
    switch (event) {
      case LoadSettingsEvent():
        await _loadSettings();
      case ToggleDarkModeEvent():
        _toggleDarkMode();
      case ToggleNotificationsEvent():
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

    emitSideEffect(SettingsUpdatedEffect(
      'Dark mode ${state.darkMode ? 'enabled' : 'disabled'}',
    ));
  }

  void _toggleNotifications() {
    emitState(state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    ));

    emitSideEffect(SettingsUpdatedEffect(
      'Notifications ${state.notificationsEnabled ? 'enabled' : 'disabled'}',
    ));
  }
}
