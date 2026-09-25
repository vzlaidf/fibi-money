import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fibi_money/features/auth/domain/models/app_user.dart';
import 'package:fibi_money/features/auth/domain/repositories/auth_repository.dart';
import 'package:fibi_money/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late StreamController<AppUser?> userStreamController;

  const testUser = AppUser(
    id: 'user_123',
    email: 'test@example.com',
    displayName: 'Test User',
    isAnonymous: false,
  );

  const guestUser = AppUser(
    id: 'guest_456',
    isAnonymous: true,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    userStreamController = StreamController<AppUser?>.broadcast();
    when(() => mockAuthRepository.user)
        .thenAnswer((_) => userStreamController.stream);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  tearDown(() {
    userStreamController.close();
  });

  group('AuthBloc', () {
    test('initial state is unauthenticated when currentUser is null', () {
      final bloc = AuthBloc(authRepository: mockAuthRepository);
      expect(bloc.state.status, equals(AuthStatus.unauthenticated));
      expect(bloc.state.user, isNull);
    });

    test('initial state is authenticated when currentUser exists', () {
      when(() => mockAuthRepository.currentUser).thenReturn(testUser);
      final bloc = AuthBloc(authRepository: mockAuthRepository);
      expect(bloc.state.status, equals(AuthStatus.authenticated));
      expect(bloc.state.user, equals(testUser));
    });

    blocTest<AuthBloc, AuthState>(
      'emits authenticated when AuthSubscriptionRequested receives user',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) async {
        bloc.add(const AuthSubscriptionRequested());
        // Permitir que el handler inicie la suscripción
        await Future<void>.delayed(Duration.zero);
        userStreamController.add(testUser);
      },
      expect: () => [
        const AuthState.authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading] and calls signInWithGoogle on AuthGoogleSignInSubmitted',
      setUp: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthGoogleSignInSubmitted()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when signInWithGoogle fails',
      setUp: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Google Sign-In canceled'));
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthGoogleSignInSubmitted()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.failure,
          errorMessage:
              'No se pudo iniciar sesión con Google: Exception: Google Sign-In canceled',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading] and calls signInAnonymously on AuthAnonymousSignInSubmitted',
      setUp: () {
        when(() => mockAuthRepository.signInAnonymously())
            .thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthAnonymousSignInSubmitted()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInAnonymously()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when signInAnonymously fails',
      setUp: () {
        when(() => mockAuthRepository.signInAnonymously())
            .thenThrow(Exception('Network error'));
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthAnonymousSignInSubmitted()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.failure,
          errorMessage:
              'No se pudo iniciar sesión como invitado: Exception: Network error',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading] and calls signOut on AuthSignOutRequested',
      setUp: () {
        when(() => mockAuthRepository.currentUser).thenReturn(guestUser);
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading, user: guestUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signOut()).called(1);
      },
    );
  });
}
