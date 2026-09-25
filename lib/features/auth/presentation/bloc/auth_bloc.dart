import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// BLoC que coordina los flujos de autenticación (Google, Anónimo, Logout).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(
          authRepository.currentUser != null
              ? AuthState.authenticated(authRepository.currentUser!)
              : const AuthState.unauthenticated(),
        ) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthGoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<AuthAnonymousSignInSubmitted>(_onAnonymousSignInSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach<AppUser?>(
      _authRepository.user,
      onData: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return const AuthState.unauthenticated();
      },
      onError: (error, stackTrace) => const AuthState.unauthenticated(),
    );
  }

  Future<void> _onGoogleSignInSubmitted(
    AuthGoogleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'No se pudo iniciar sesión con Google: $e',
        ),
      );
    }
  }

  Future<void> _onAnonymousSignInSubmitted(
    AuthAnonymousSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.signInAnonymously();
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'No se pudo iniciar sesión como invitado: $e',
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Error al cerrar sesión: $e',
        ),
      );
    }
  }
}
