import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Estado inmutable que representa la configuración actual del tema.
class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = ThemeMode.system,
  });

  final ThemeMode themeMode;

  /// Retorna si el modo actual seleccionado es oscuro.
  /// Si el modo es `system`, se evalúa el brillo actual del sistema recibido por parámetro.
  bool isDark([Brightness? systemBrightness]) {
    return switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => systemBrightness == Brightness.dark,
    };
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode];
}
