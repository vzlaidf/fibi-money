import 'package:equatable/equatable.dart';

/// Eventos para el [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita iniciar la suscripción al stream de cambios de sesión.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// Solicita autenticación mediante Google Sign-In.
final class AuthGoogleSignInSubmitted extends AuthEvent {
  const AuthGoogleSignInSubmitted();
}

/// Solicita autenticación como usuario invitado/anónimo.
final class AuthAnonymousSignInSubmitted extends AuthEvent {
  const AuthAnonymousSignInSubmitted();
}

/// Solicita el cierre de sesión activo.
final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
