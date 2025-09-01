import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'database.dart';

///signout method is essential.
class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;
  final String _serverCliendId =
      "97362753510-o048dnbkrhopfuffqbjndhd06nugdouk.apps.googleusercontent.com";

  Auth() {
    _initializeGoogleSignIn();
  }

  MathUser? _userFromFireBase(User? user) {
    return user != null ? MathUser(uid: user.uid) : null;
  }

  Stream<MathUser?> get mathUser {
    return _auth.authStateChanges().map(_userFromFireBase);
  }

  Future loginInAnonymously() async {
    try {
      UserCredential credential = await _auth.signInAnonymously();
      User? user = credential.user;
      await DatabaseService(uid: user!.uid).addUserData("Player", {
        "addition": "0",
        "substraction": "0",
        "complex": "0",
      });
      return _userFromFireBase(user);
    } catch (e) {
      print(e.toString()); // TODO
      return null;
    }
  }

  Future<bool> _checkAnonymousUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final isUserAnon = user.isAnonymous;
      return isUserAnon;
    } else {
      return false;
    }
  }

  Future<MathUser?> linkAnonymousWithCredentials(
    String email,
    String password,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await currentUser?.linkWithCredential(credential);
      User? user = userCredential?.user;

      return _userFromFireBase(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      return _userFromFireBase(user);
    } catch (e) {
      print(e.toString()); // TODO
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      await DatabaseService(uid: user!.uid).addUserData("Player", {
        "addition": "0",
        "substraction": "0",
        "complex": "0",
      });

      return _userFromFireBase(user);
    } catch (e) {
      print(e.toString()); // TODO
      return null;
    }
  }

  Future updateName(String name) async {
    try {
      User? user = _auth.currentUser;
      dynamic result = await DatabaseService(uid: user!.uid).updateName(name);
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future updateUserEmailAndPassword(String email, String password) async {
        if (await _checkAnonymousUser() == false) {

      try {
        User? user = _auth.currentUser;
        String? currentEmail = user?.email;
        if (email != currentEmail && email.isNotEmpty) {
          await user!.verifyBeforeUpdateEmail(email);
        }
        if (password.isNotEmpty) {
          await user!.updatePassword(password);
        }
        return _userFromFireBase(user);
      } catch (e) {
        print(e.toString());
        return null;
      }
    } else {
      return linkAnonymousWithCredentials(email, password);
    }
  }

  Future getEmail() async {
    User? user = _auth.currentUser;
    return user?.email;
  }

  Future getUid() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print(e.toString()); // TODO
      return null;
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _serverCliendId);
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<UserCredential> _googleSignInSupport(
    GoogleSignInAccount account,
  ) async {
    final googleAuth = account.authentication;
    final authClient = _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes(['email']);

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    final User user = userCredential.user!;
    await DatabaseService(
      uid: user.uid,
    ).addUserData("Player", {"addition": "0", "substraction": "0","complex":"0"});
    return userCredential;
  }

  Future<MathUser?> signInWithGoogle() async {
    _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      final UserCredential userCredential = await _googleSignInSupport(account);

      return _userFromFireBase(userCredential.user);
    } on GoogleSignInException catch (e) {
      print(
        'Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}, error: $e',
      );
      rethrow;
    } catch (error) {
      print('Unexpected Google Sign-In error: $error');
      rethrow;
    }
  }

  Future<MathUser?> attemptSilentSignIn() async {
    _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount? account = await _googleSignIn
          .attemptLightweightAuthentication();
      if (account is Future<GoogleSignInAccount>) {
        final UserCredential userCredential = await _googleSignInSupport(
          account!,
        );

        return _userFromFireBase(userCredential.user);
      } else {
        return null;
      }
    } catch (e) {
      print("The silent signin has failed! ${e.toString()}");
      return null;
    }
  }
}
