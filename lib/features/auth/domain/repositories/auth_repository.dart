import '../models/app_user.dart';

/// Contrato abstracto para las operaciones de autenticación de usuario.
abstract interface class AuthRepository {
  /// Stream que emite el estado actual del usuario cada vez que cambia la sesión.
  Stream<AppUser?> get user;

  /// Retorna el usuario actualmente autenticado o null si no hay sesión activa.
  AppUser? get currentUser;

  /// Inicia sesión utilizando Google Sign-In.
  Future<void> signInWithGoogle();

  /// Inicia sesión en modo anónimo (invitado).
  Future<void> signInAnonymously();

  /// Cierra la sesión activa actual.
  Future<void> signOut();
}
