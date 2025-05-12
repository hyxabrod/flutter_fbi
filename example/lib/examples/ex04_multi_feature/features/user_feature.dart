import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/user_entities.dart';

class UserFeature extends Feature<UserEvent, UserState, UserSideEffect> {
  UserFeature() : super(initialState: UserState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(UserEvent event) async {
    if (event is LoadUserEvent) {
      await _loadUser();
    } else if (event is UpdateUserNameEvent) {
      await _updateUserName(event.name);
    }
  }

  Future<void> _loadUser() async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    emitState(state.copyWith(
      isLoading: false,
      name: 'John Doe',
      email: 'john.doe@example.com',
    ));
  }

  Future<void> _updateUserName(String name) async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (name.isEmpty) {
      emitState(state.copyWith(
        isLoading: false,
        error: 'Name cannot be empty',
      ));
      return;
    }

    emitState(state.copyWith(
      isLoading: false,
      name: name,
    ));

    emitSifeEffect(UserUpdatedEffect('Name updated successfully'));
  }
}
