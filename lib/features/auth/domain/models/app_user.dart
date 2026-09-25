import 'package:equatable/equatable.dart';

/// Modelo de dominio inmutable que representa al usuario autenticado en la aplicación.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  /// Identificador único del usuario (UID de Firebase).
  final String id;

  /// Correo electrónico del usuario (null si es anónimo sin email).
  final String? email;

  /// Nombre para mostrar (del perfil de Google o null).
  final String? displayName;

  /// URL de la imagen de perfil del usuario.
  final String? photoUrl;

  /// Indica si el usuario inició sesión en modo invitado/anónimo.
  final bool isAnonymous;

  /// Nombre amigable a mostrar en la interfaz.
  String get visibleName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.trim().isNotEmpty) {
      return email!.split('@').first;
    }
    return 'Invitado';
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, isAnonymous];
}
