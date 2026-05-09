part of 'sig_up_bloc.dart';

@immutable
sealed class SigUpState {}

final class SigUpInitial extends SigUpState {}

final class SignUpLoading extends SigUpState {}

final class SignUpSuccess extends SigUpState {
  final String uid;
  SignUpSuccess({required this.uid});
}

final class SignUpFailure extends SigUpState {
  final String error;
  SignUpFailure({required this.error});
}

////// ADD LOGIN 

final class LoginLoading extends SigUpState {}

final class LoginSuccess extends SigUpState {
  final String uid;
  LoginSuccess({required this.uid});
}

final class LoginFailure extends SigUpState {
  final String error;
  LoginFailure({required this.error});
}
