import 'package:flutter/material.dart' hide FormState;
import 'package:flutter_fbi/flutter_fbi.dart';
import '../entities/form_entities.dart';
import '../features/form_feature.dart';

/// Form binder that perfectly demonstrates DisposableBinderProvider usage.
///
/// Why DisposableBinderProvider is ideal here:
/// 1. Form state should be temporary - disposed when leaving the screen
/// 2. We don't want form data to persist accidentally
/// 3. Each form instance should start fresh
/// 4. Automatic cleanup prevents memory leaks
class FormBinder extends FeatureBinder<FormEvent, FormState, FormUiState, FormSideEffect> {
  FormBinder({required super.context})
      : super(
          feature: FormFeature(),
          uiStatePreprocessor: () => const FormUiState(
            isLoading: false,
            name: '',
            email: '',
            isSubmitting: false,
            isSubmitted: false,
            canSubmit: false,
          ),
        ) {
    // Handle side effects
    bindSideEffect(_handleSideEffect);

    // Auto-load form data when binder is created
    loadData();
  }

  @override
  FormUiState uiStateTransformer(FormState featureState) {
    return FormUiState(
      isLoading: featureState.isLoading,
      name: featureState.name,
      email: featureState.email,
      isSubmitting: featureState.isSubmitting,
      isSubmitted: featureState.isSubmitted,
      canSubmit: _canSubmit(featureState),
      nameError: _getNameError(featureState.error),
      emailError: _getEmailError(featureState.error),
      generalError: _getGeneralError(featureState.error),
    );
  }

  bool _canSubmit(FormState state) {
    return !state.isLoading &&
        !state.isSubmitting &&
        !state.isSubmitted &&
        state.name.isNotEmpty &&
        state.email.isNotEmpty;
  }

  String? _getNameError(String? error) {
    if (error?.contains('name') == true || error?.contains('fields') == true) {
      return error;
    }
    return null;
  }

  String? _getEmailError(String? error) {
    if (error?.contains('email') == true) {
      return error;
    }
    return null;
  }

  String? _getGeneralError(String? error) {
    if (error != null && 
        !error.contains('name') && 
        !error.contains('email') && 
        !error.contains('fields')) {
      return error;
    }
    return null;
  }

  void _handleSideEffect(FormSideEffect sideEffect) {
    switch (sideEffect) {
      case ShowSuccessMessageEffect():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sideEffect.message),
            backgroundColor: Colors.green,
          ),
        );
      case ShowErrorMessageEffect():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sideEffect.message),
            backgroundColor: Colors.red,
          ),
        );
      case NavigateBackEffect():
        Navigator.of(context).pop();
    }
  }

  void loadData() => feature.add(LoadFormDataEvent());
  void updateName(String name) => feature.add(UpdateNameEvent(name));
  void updateEmail(String email) => feature.add(UpdateEmailEvent(email));
  void submitForm() => feature.add(SubmitFormEvent());
  void resetForm() => feature.add(ResetFormEvent());
}
