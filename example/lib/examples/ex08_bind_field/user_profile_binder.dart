import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex08_bind_field/user_profile_state.dart';

class UserProfileBinder extends SimpleBinder<UserProfileState> {
  UserProfileBinder({required super.context})
      : super(
          uiStatePreprocessor: () => const UserProfileState(),
        );

  void updateName(String name) {
    emitUiState(state.copyWith(name: name));
  }

  void incrementAge() {
    emitUiState(state.copyWith(age: state.age + 1));
  }

  void decrementAge() {
    emitUiState(state.copyWith(age: state.age - 1));
  }

  void updateEmail(String email) {
    emitUiState(state.copyWith(email: email));
  }

  void togglePremium() {
    emitUiState(state.copyWith(isPremium: !state.isPremium));
  }

  void reset() {
    emitUiState(const UserProfileState());
  }
}
