import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class SettingsEvent extends UiEvent {}

class LoadSettingsEvent extends SettingsEvent {}

class ToggleDarkModeEvent extends SettingsEvent {}

class ToggleNotificationsEvent extends SettingsEvent {}

// State
class SettingsState extends FeatureState {
  final bool isLoading;
  final bool darkMode;
  final bool notificationsEnabled;
  final String? error;

  const SettingsState({
    this.isLoading = false,
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.error,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? darkMode,
    bool? notificationsEnabled,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, darkMode, notificationsEnabled, error];
}

// Side Effect
abstract class SettingsSideEffect extends SideEffect {}

class SettingsUpdatedEffect extends SettingsSideEffect {
  final String message;
  SettingsUpdatedEffect(this.message);
}
