import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import '../binders/form_binder.dart';
import '../entities/form_entities.dart';

/// Example screen demonstrating DisposableBinderProvider.
///
/// This is a PERFECT use case for DisposableBinderProvider because:
///
/// 1. **Route-level lifecycle**: Form binder created when screen opens,
///    automatically disposed when screen closes
///
/// 2. **Temporary state**: Form data should NOT persist when user navigates away
///
/// 3. **Fresh start**: Each time user opens form, it should start clean
///
/// 4. **Memory safety**: No manual dispose() needed - prevents memory leaks
///
/// Compare this to using regular BinderProvider where you'd need:
/// - StatefulWidget with manual lifecycle management
/// - Easy to forget dispose() calls
/// - Risk of memory leaks
/// - More boilerplate code
class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposableBinderProvider<FormBinder>(
      // Binder created here when screen opens
      create: (context) => FormBinder(context: context),
      child: const _FormContent(),
    );
    // Binder automatically disposed when screen closes!
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent();

  @override
  Widget build(BuildContext context) {
    final binder = context.findBinder<FormBinder>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DisposableBinderProvider Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: binder.bindState((context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InfoCard(),
              const SizedBox(height: 20),
              Expanded(child: _FormCard(binder: binder, state: state)),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'DisposableBinderProvider Benefits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✓ Automatic lifecycle management\n'
              '✓ No memory leaks - auto dispose\n'
              '✓ Fresh state on each screen visit\n'
              '✓ Perfect for temporary form data\n'
              '✓ Less boilerplate than manual management',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final FormBinder binder;
  final FormUiState state;

  const _FormCard({
    required this.binder,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Information Form',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (state.isLoading) ...[
              const _LoadingIndicator(),
            ] else ...[
              _NameField(
                value: state.name,
                onChanged: binder.updateName,
                error: state.nameError,
              ),
              const SizedBox(height: 16),
              _EmailField(
                value: state.email,
                onChanged: binder.updateEmail,
                error: state.emailError,
              ),
              const SizedBox(height: 20),
              if (state.generalError != null) _ErrorContainer(error: state.generalError!),
              if (state.isSubmitted) const _SuccessContainer(),
              const Spacer(),
              _ActionButtons(
                canReset: !state.isSubmitting,
                canSubmit: state.canSubmit && !state.isSubmitting,
                isSubmitting: state.isSubmitting,
                onReset: binder.resetForm,
                onSubmit: binder.submitForm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 16),
        Text(
          'Loading form data...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;

  const _NameField({
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Name',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
        errorText: error,
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;

  const _EmailField({
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email),
        errorText: error,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
    );
  }
}

class _ErrorContainer extends StatelessWidget {
  final String error;

  const _ErrorContainer({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessContainer extends StatelessWidget {
  const _SuccessContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            'Form submitted successfully!',
            style: TextStyle(color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool canReset;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onReset;
  final VoidCallback onSubmit;

  const _ActionButtons({
    required this.canReset,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onReset,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: canReset ? onReset : null,
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
