part of 'home_bloc.dart';

@immutable
sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPosts extends HomeEvent {}

class FetchNextPage extends HomeEvent {
  final String pageToken;

  FetchNextPage(this.pageToken);

  @override
  List<Object?> get props => [pageToken];
}

