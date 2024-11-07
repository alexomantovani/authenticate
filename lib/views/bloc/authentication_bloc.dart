import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthenticationBloc() : super(const AuthenticationInitial()) {
    on<SignUpEvent>(_signUpHandler);
    on<SignInEvent>(_signInHandler);
    on<SignOutEvent>(_signOutHandler);
    on<DeleteAccountEvent>(_deleteAccountHandler);
    on<ResetPasswordEvent>(_resetPasswordHandler);
  }

  Future<void> _signUpHandler(
      SignUpEvent event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        emit(const Authenticated());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' || e.code == 'weak-password') {
        emit(AuthenticationError(e.message.toString()));
      } else {
        emit(const AuthenticationError(
            'It was not possible to complete your request'));
      }
    }
  }

  Future<void> _signInHandler(
      SignInEvent event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        emit(SignedIn(userCredential));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(AuthenticationError(e.message.toString()));
      } else {
        emit(const AuthenticationError(
            'It was not possible to complete your request'));
      }
    }
  }

  Future<void> _signOutHandler(
      SignOutEvent event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    try {
      await _auth.signOut();
      emit(const SignedOut());
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(e.message.toString()));
    }
  }

  Future<void> _deleteAccountHandler(
      DeleteAccountEvent event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    try {
      if (event.user != null) {
        await event.user!.delete();
        emit(const UnAuthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(e.message.toString()));
    }
  }

  Future<void> _resetPasswordHandler(
      ResetPasswordEvent event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      emit(const ForgotPasswordSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(e.message.toString()));
    }
  }
}
