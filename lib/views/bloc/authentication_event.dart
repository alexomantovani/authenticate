part of 'authentication_bloc.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

class SignUpEvent extends AuthenticationEvent {
  const SignUpEvent({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  List<String> get props => [email, password, fullName];
}

class SignInEvent extends AuthenticationEvent {
  const SignInEvent({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  List<String> get props => [email, password];
}

class SignOutEvent extends AuthenticationEvent {
  const SignOutEvent();
}

class DeleteAccountEvent extends AuthenticationEvent {
  final User? user;

  const DeleteAccountEvent(this.user);

  List<Object> get props => [user!];
}

class ResetPasswordEvent extends AuthenticationEvent {
  final String email;

  const ResetPasswordEvent(this.email);

  List<Object> get props => [email];
}
