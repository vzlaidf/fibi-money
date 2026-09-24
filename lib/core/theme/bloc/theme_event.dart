import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Eventos base para la gestión del tema de la aplicación.
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado cuando se selecciona un modo de tema explícito.
class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

/// Evento para alternar rápidamente entre modo claro y oscuro.
class ThemeModeToggled extends ThemeEvent {
  const ThemeModeToggled();
}
