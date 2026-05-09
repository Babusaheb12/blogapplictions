part of 'home_bloc.dart';

@immutable
sealed class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<dynamic> posts;
  final String? nextPageToken;

  HomeLoaded({required this.posts, this.nextPageToken});

  @override
  List<Object?> get props => [posts, nextPageToken];
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

