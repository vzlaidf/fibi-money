import 'package:bloc_test/bloc_test.dart';
import 'package:fibi_money/core/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeBloc', () {
    test('initial state has ThemeMode.system by default', () {
      final bloc = ThemeBloc();
      expect(bloc.state.themeMode, equals(ThemeMode.system));
      bloc.close();
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeState with ThemeMode.dark when ThemeModeChanged is added',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ThemeModeChanged(ThemeMode.dark)),
      expect: () => [
        const ThemeState(themeMode: ThemeMode.dark),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeState with ThemeMode.light when ThemeModeChanged is added',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ThemeModeChanged(ThemeMode.light)),
      expect: () => [
        const ThemeState(themeMode: ThemeMode.light),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'toggles from light to dark on ThemeModeToggled',
      build: () => ThemeBloc(initialMode: ThemeMode.light),
      act: (bloc) => bloc.add(const ThemeModeToggled()),
      expect: () => [
        const ThemeState(themeMode: ThemeMode.dark),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'toggles from dark to light on ThemeModeToggled',
      build: () => ThemeBloc(initialMode: ThemeMode.dark),
      act: (bloc) => bloc.add(const ThemeModeToggled()),
      expect: () => [
        const ThemeState(themeMode: ThemeMode.light),
      ],
    );

    test('isDark helper returns correct boolean', () {
      expect(const ThemeState(themeMode: ThemeMode.dark).isDark(), isTrue);
      expect(const ThemeState(themeMode: ThemeMode.light).isDark(), isFalse);
      expect(
        const ThemeState(themeMode: ThemeMode.system).isDark(Brightness.dark),
        isTrue,
      );
      expect(
        const ThemeState(themeMode: ThemeMode.system).isDark(Brightness.light),
        isFalse,
      );
    });
  });
}
