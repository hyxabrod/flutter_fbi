import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/user_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/entities/user_entities.dart';

void main() {
  featureTest<UserEvent, UserState, UserSideEffect>(
    'UserFeature load user success',
    build: () => UserFeature(),
    act: (feature) => feature.add(LoadUserEvent()),
    expect: () => [
      isA<UserState>().having((s) => s.isLoading, 'isLoading', true),
      isA<UserState>().having((s) => s.name, 'name', 'John Doe'),
    ],
  );

  featureTest<UserEvent, UserState, UserSideEffect>(
    'UserFeature update name success and emits side effect',
    build: () => UserFeature(),
    act: (feature) => feature.add(UpdateUserNameEvent('Alice')),
    expect: () => [
      isA<UserState>().having((s) => s.isLoading, 'isLoading', true),
      isA<UserState>().having((s) => s.name, 'name', 'Alice'),
    ],
  );

  featureTest<UserEvent, UserState, UserSideEffect>(
    'UserFeature update name success - side effects',
    build: () => UserFeature(),
    act: (feature) => feature.add(UpdateUserNameEvent('Alice')),
    expectSideEffects: () => [isA<UserUpdatedEffect>().having((e) => e.message, 'message', contains('Name updated'))],
  );

  featureTest<UserEvent, UserState, UserSideEffect>(
    'UserFeature update name empty produces error',
    build: () => UserFeature(),
    act: (feature) => feature.add(UpdateUserNameEvent('')),
    expect: () => [
      isA<UserState>().having((s) => s.isLoading, 'isLoading', true),
      isA<UserState>().having((s) => s.error, 'error', 'Name cannot be empty'),
    ],
  );
}
