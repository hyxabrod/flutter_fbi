import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex08_bind_field/user_profile_binder.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposableBinderProvider<UserProfileBinder>(
      create: (context) => UserProfileBinder(context: context),
      child: const _UserProfileContent(),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  const _UserProfileContent();

  @override
  Widget build(BuildContext context) {
    final binder = context.findBinder<UserProfileBinder>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('bindField Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Name field - uses bindField to listen only to name changes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name (bindField)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    binder.bindField(
                      selector: (state) => state.name,
                      builder: (context, name) {
                        return Text(
                          name,
                          style: const TextStyle(fontSize: 18),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => binder.updateName('Alice'),
                            child: const Text('Set Alice'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => binder.updateName('Bob'),
                            child: const Text('Set Bob'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Age field - uses bindField to listen only to age changes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Age (bindField)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    binder.bindField(
                      selector: (state) => state.age,
                      builder: (context, age) {
                        return Text(
                          '$age years old',
                          style: const TextStyle(fontSize: 18),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: binder.decrementAge,
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: binder.incrementAge,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email field - uses bindField to listen only to email changes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email (bindField)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    binder.bindField(
                      selector: (state) => state.email,
                      builder: (context, email) {
                        return Text(
                          email,
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => binder.updateEmail('alice@example.com'),
                            child: const Text('Alice Email'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => binder.updateEmail('bob@example.com'),
                            child: const Text('Bob Email'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Premium status - uses bindField to listen only to isPremium changes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Status (bindField)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    binder.bindField(
                      selector: (state) => state.isPremium,
                      builder: (context, isPremium) {
                        return Row(
                          children: [
                            Icon(
                              isPremium ? Icons.star : Icons.star_border,
                              color: isPremium ? Colors.amber : Colors.grey,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPremium ? 'Premium User' : 'Free User',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: binder.togglePremium,
                      child: const Text('Toggle Premium'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Reset button and info card
            ElevatedButton(
              onPressed: binder.reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset All'),
            ),
            const SizedBox(height: 16),

            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'bindField Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This example demonstrates the bindField method, which allows you to listen to changes '
                      'in a specific field of the state instead of the entire state. Each widget above only '
                      'rebuilds when its specific field changes, improving performance for complex states.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
