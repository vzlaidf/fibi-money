import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

/// BLoC responsable de gestionar el modo de tema de la aplicación.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({ThemeMode initialMode = ThemeMode.system})
      : super(ThemeState(themeMode: initialMode)) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<ThemeModeToggled>(_onThemeModeToggled);
  }

  void _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onThemeModeToggled(
    ThemeModeToggled event,
    Emitter<ThemeState> emit,
  ) {
    final nextMode = switch (state.themeMode) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
    };
    emit(state.copyWith(themeMode: nextMode));
  }
}
