import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class NewsEvent extends UiEvent {}

class LoadNewsEvent extends NewsEvent {}

// State
class NewsState extends FeatureState {
  final bool isLoading;
  final List<String> news;
  final String? error;

  const NewsState({
    this.isLoading = false,
    this.news = const [],
    this.error,
  }) : super();

  NewsState copyWith({
    bool? isLoading,
    List<String>? news,
    String? error,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      news: news ?? this.news,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, news, error];
}

// Side Effect
abstract class NewsSideEffect extends SideEffect {}

class NewsErrorEffect extends NewsSideEffect {
  final String message;
  NewsErrorEffect(this.message);
}
