import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación usando Firebase Auth y Google Sign-In.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            '573734690175-6kbnjscip3iu3oto1s5bnnlseo9ail2m.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  @override
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUserToAppUser);
  }

  @override
  AppUser? get currentUser {
    return _mapFirebaseUserToAppUser(_firebaseAuth.currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = fb_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AppUser? _mapFirebaseUserToAppUser(fb_auth.User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }
}
