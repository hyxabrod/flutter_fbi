import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/settings_entities.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/user_entities.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/settings_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/user_feature.dart';

// Combined UI State
class DashboardState extends BinderState {
  final bool isLoading;
  final String? userName;
  final String? userEmail;
  final bool darkMode;
  final bool notificationsEnabled;
  final String? error;

  DashboardState({
    required this.isLoading,
    this.userName,
    this.userEmail,
    required this.darkMode,
    required this.notificationsEnabled,
    this.error,
  });

  @override
  List<Object?> get props => [isLoading, userName, userEmail, darkMode, notificationsEnabled, error];
}

class DashboardBinder extends MultiFeatureBinder<DashboardState> {
  late UserFeature userFeature;
  late SettingsFeature settingsFeature;
  DashboardBinder({required BuildContext context, required List<Feature> features})
      : super(
          context: context,
          features: features,
          shouldWaitForAllFeatures: false, // Updates UI immediately when any feature emits state
          uiStatePreprocessor: () => DashboardState(
            isLoading: true,
            darkMode: false,
            notificationsEnabled: true,
          ),
        ) {
    userFeature = features.last as UserFeature;
    settingsFeature = features.first as SettingsFeature;

    _setupSideEffectHandling();

    userFeature.add(LoadUserEvent());
    settingsFeature.add(LoadSettingsEvent());
  }

  void _setupSideEffectHandling() {
    bindSideEffect((effect) {
      if (effect is UserUpdatedEffect || effect is SettingsUpdatedEffect) {
        String message = '';

        if (effect is UserUpdatedEffect) {
          message = effect.message;
        } else if (effect is SettingsUpdatedEffect) {
          message = effect.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  void updateUserName(String name) {
    userFeature.add(UpdateUserNameEvent(name));
  }

  void toggleDarkMode() {
    settingsFeature.add(ToggleDarkModeEvent());
  }

  void toggleNotifications() {
    settingsFeature.add(ToggleNotificationsEvent());
  }

  @override
  DashboardState uiStateTransformer(List<FeatureState> featureStates) {
    UserState? userState;
    SettingsState? settingsState;

    for (var state in featureStates) {
      if (state is UserState) {
        userState = state;
      } else if (state is SettingsState) {
        settingsState = state;
      }
    }

    final user = userState ?? UserState();
    final settings = settingsState ?? SettingsState();

    return DashboardState(
      isLoading: user.isLoading || settings.isLoading,
      userName: user.name,
      userEmail: user.email,
      darkMode: settings.darkMode,
      notificationsEnabled: settings.notificationsEnabled,
      error: user.error ?? settings.error,
    );
  }
}
