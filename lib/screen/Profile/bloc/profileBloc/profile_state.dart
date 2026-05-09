part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final String name;
  final String email;

  ProfileLoaded({required this.name, required this.email});
}

final class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error});
}
