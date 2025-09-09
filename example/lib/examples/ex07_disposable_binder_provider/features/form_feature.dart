import 'package:flutter_fbi/flutter_fbi.dart';
import '../entities/form_entities.dart';

/// Form feature that manages temporary form state.
/// Perfect example for DisposableBinderProvider usage -
/// state should not persist when leaving the form.
class FormFeature extends Feature<FormEvent, FormState, FormSideEffect> {
  FormFeature() : super(initialState: const FormState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(FormEvent event) async {
    switch (event) {
      case LoadFormDataEvent():
        await _loadFormData();
      case UpdateNameEvent():
        _updateName(event.name);
      case UpdateEmailEvent():
        _updateEmail(event.email);
      case SubmitFormEvent():
        await _submitForm();
      case ResetFormEvent():
        _resetForm();
    }
  }

  Future<void> _loadFormData() async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate loading existing form data (e.g., for editing)
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock pre-filled data
    emitState(state.copyWith(
      isLoading: false,
      name: 'John Doe',
      email: 'john@example.com',
    ));
  }

  void _updateName(String name) {
    emitState(state.copyWith(name: name, error: null));
  }

  void _updateEmail(String email) {
    emitState(state.copyWith(email: email, error: null));
  }

  Future<void> _submitForm() async {
    if (state.name.isEmpty || state.email.isEmpty) {
      emitState(state.copyWith(error: 'Please fill all fields'));
      emitSideEffect(ShowErrorMessageEffect('All fields are required'));
      return;
    }

    if (!_isValidEmail(state.email)) {
      emitState(state.copyWith(error: 'Invalid email format'));
      emitSideEffect(ShowErrorMessageEffect('Please enter a valid email'));
      return;
    }

    emitState(state.copyWith(isSubmitting: true, error: null));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate random failure (20% chance)
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('Network error');
      }

      emitState(state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
      ));

      emitSideEffect(ShowSuccessMessageEffect('Form submitted successfully!'));

      // Navigate back after success
      await Future.delayed(const Duration(seconds: 1));
      emitSideEffect(NavigateBackEffect());
    } catch (error) {
      emitState(state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit: ${error.toString()}',
      ));
      emitSideEffect(ShowErrorMessageEffect('Failed to submit form'));
    }
  }

  void _resetForm() {
    emitState(const FormState());
    emitSideEffect(ShowSuccessMessageEffect('Form reset'));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
