import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class FormEvent extends UiEvent {}

class LoadFormDataEvent extends FormEvent {}

class UpdateNameEvent extends FormEvent {
  final String name;
  UpdateNameEvent(this.name);
}

class UpdateEmailEvent extends FormEvent {
  final String email;
  UpdateEmailEvent(this.email);
}

class SubmitFormEvent extends FormEvent {}

class ResetFormEvent extends FormEvent {}

// Feature State
class FormState extends FeatureState {
  final bool isLoading;
  final String name;
  final String email;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? error;

  const FormState({
    this.isLoading = false,
    this.name = '',
    this.email = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.error,
  });

  FormState copyWith({
    bool? isLoading,
    String? name,
    String? email,
    bool? isSubmitting,
    bool? isSubmitted,
    String? error,
  }) {
    return FormState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, name, email, isSubmitting, isSubmitted, error];
}

// UI State
class FormUiState extends BinderState {
  final bool isLoading;
  final String name;
  final String email;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool canSubmit;
  final String? nameError;
  final String? emailError;
  final String? generalError;

  const FormUiState({
    required this.isLoading,
    required this.name,
    required this.email,
    required this.isSubmitting,
    required this.isSubmitted,
    required this.canSubmit,
    this.nameError,
    this.emailError,
    this.generalError,
  });

  @override
  List<Object?> get props => [isLoading, name, email, isSubmitting, isSubmitted, canSubmit, nameError, emailError, generalError];
}

// Side Effects
abstract class FormSideEffect extends SideEffect {}

class ShowSuccessMessageEffect extends FormSideEffect {
  final String message;
  ShowSuccessMessageEffect(this.message);
}

class ShowErrorMessageEffect extends FormSideEffect {
  final String message;
  ShowErrorMessageEffect(this.message);
}

class NavigateBackEffect extends FormSideEffect {}