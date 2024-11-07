part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

final class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

final class Authenticated extends AuthenticationState {
  const Authenticated();
}

final class UnAuthenticated extends AuthenticationState {
  const UnAuthenticated();
}

final class SignedOut extends AuthenticationState {
  const SignedOut();
}

final class SignedIn extends AuthenticationState {
  final UserCredential userCredential;

  const SignedIn(this.userCredential);

  @override
  List<Object> get props => [userCredential];
}

final class ForgotPasswordSent extends AuthenticationState {
  const ForgotPasswordSent();
}

class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object> get props => [message];
}
