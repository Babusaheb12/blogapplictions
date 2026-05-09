part of 'sig_up_bloc.dart';

@immutable
sealed class SigUpEvent {}

class SignUpSubmitted extends SigUpEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  SignUpSubmitted({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });
}

////// ADD LOGIN 

class LoginSubmitted extends SigUpEvent {
  final String email;
  final String password;

  LoginSubmitted({
    required this.email,
    required this.password,
  });
}

class GoogleSignInSubmitted extends SigUpEvent {}


