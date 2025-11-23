import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/dashboard_with_wait_binder.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/news_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/weather_feature.dart';

/// Example demonstrating MultiFeatureBinder with [shouldWaitForAllFeatures] = true
/// When true: UI only updates after all features have emitted their states
/// When false: UI updates as soon as any feature emits a new state
class DashboardWithWaitScreen extends StatelessWidget {
  const DashboardWithWaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize features with error simulation enabled
    final binder = DashboardWithWaitBinder(
      context: context,
      features: [
        NewsFeature(errorRate: 0.3), // 30% chance of error
        WeatherFeature(errorRate: 0.3), // 30% chance of error
      ],
    );

    return _DashboardWithWaitWidget(binder: binder);
  }
}

class _DashboardWithWaitWidget extends BoundWidget<DashboardWithWaitBinder> {
  const _DashboardWithWaitWidget({required super.binder});

  @override
  Widget builder(BuildContext context, DashboardWithWaitBinder binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Feature with Wait for All'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: binder.refreshData,
            tooltip: 'Refresh data (30% error chance)',
          ),
        ],
      ),
      body: binder.bindState((context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and explanation
              const Text(
                'Dashboard with Wait',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'shouldWaitForAllFeatures = true',
// This example demonstrates: the UI will only update when all features have emitted their state.
// ("Wait for all" mode, see binder for details.)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Both features must emit states before the UI updates. '
                        'News loads in 3s, Weather in 1s. Each refresh has a 30% chance of error.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading indicators
              Row(
                children: [
                  Expanded(
                    child: _LoadingIndicator(
                      label: 'News',
                      isLoading: state.isNewsLoading,
                      loadTime: state.newsLoadTime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LoadingIndicator(
                      label: 'Weather',
                      isLoading: state.isWeatherLoading,
                      loadTime: state.weatherLoadTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (state.error != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Waiting for all features to load...',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Both features must complete loading',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weather Section
                            const Text(
                              'Weather',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.temperature,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        Text(
                                          state.weatherCondition,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // News Section
                            const Text(
                              'News',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: state.news.isEmpty
                                      ? [
                                          const Text('No news available',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ))
                                        ]
                                      : state.news
                                          .map((item) => Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(item),
                                              ))
                                          .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final String label;
  final bool isLoading;
  final String? loadTime;

  const _LoadingIndicator({
    required this.label,
    required this.isLoading,
    this.loadTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isLoading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isLoading
                        ? 'Loading...'
                        : loadTime != null
                            ? 'Loaded in $loadTime'
                            : 'Ready',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
