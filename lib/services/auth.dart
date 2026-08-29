import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_math/shared/authresult.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'database.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _serverClientId =
      "97362753510-o048dnbkrhopfuffqbjndhd06nugdouk.apps.googleusercontent.com";
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: _serverClientId,
  );

  MathUser? _userFromFireBase(User? user) {
    return user != null ? MathUser(uid: user.uid) : null;
  }

  Stream<MathUser?> get mathUser {
    return _auth.authStateChanges().map(_userFromFireBase);
  }

  Future<AuthResult<MathUser?>> loginInAnonymously() async {
    try {
      UserCredential credential = await _auth.signInAnonymously();
      User? user = credential.user;
      await DatabaseService(
        uid: user!.uid,
      ).addUserData("Player", gameRecordInitialization);
      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Something went wrong. Please try again later.");
    }
  }

  Future<bool> checkAnonymousUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final isUserAnon = user.isAnonymous;
      return isUserAnon;
    } else {
      return false;
    }
  }

  Future<AuthResult<MathUser?>> linkAnonymousWithCredentials(
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

      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Failed to link account. Please try again.");
    }
  }

  Future<AuthResult<MathUser?>> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Login failed. Please check your credentials.");
    }
  }

  Future<AuthResult<MathUser?>> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      await DatabaseService(
        uid: user!.uid,
      ).addUserData("Player", gameRecordInitialization);
      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Registration failed. Please try again.");
    }
  }

  Future<AuthResult<dynamic>> updateName(String name) async {
    try {
      User? user = _auth.currentUser;
      dynamic result = await DatabaseService(uid: user!.uid).updateName(name);
      return AuthResult.success(result);
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Could not update name. Please try again.");
    }
  }

  Future<AuthResult<MathUser?>> updateUserEmailAndPassword(
    String email,
    String password,
  ) async {
    if (await checkAnonymousUser() == false) {
      try {
        User? user = _auth.currentUser;
        String? currentEmail = user?.email;
        if (email != currentEmail && email.isNotEmpty) {
          await user!.verifyBeforeUpdateEmail(email);
        }
        if (password.isNotEmpty) {
          await user!.updatePassword(password);
        }
        return AuthResult.success(_userFromFireBase(user));
      } on FirebaseException catch (e) {
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      } catch (e) {
        return AuthResult.failure("Update failed. Please try again.");
      }
    } else {
      return linkAnonymousWithCredentials(email, password);
    }
  }

  Future<AuthResult<MathUser?>> updatePassword(String password) async {
    if (await checkAnonymousUser() == false) {
      try {
        User? user = _auth.currentUser;
        if (password.isNotEmpty) {
          await user!.updatePassword(password);
        }
        return AuthResult.success(_userFromFireBase(user));
      } on FirebaseException catch (e) {
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      } catch (e) {
        return AuthResult.failure("Password update failed. Please try again.");
      }
    } else {
      return AuthResult.failure("Anonymous users cannot update password directly.");
    }
  }

  Future<AuthResult<MathUser?>> updateEmail(String email) async {
    if (await checkAnonymousUser() == false) {
      try {
        User? user = _auth.currentUser;
        String? currentEmail = user?.email;
        if (email != currentEmail && email.isNotEmpty) {
          await user!.verifyBeforeUpdateEmail(email);
        }
        return AuthResult.success(_userFromFireBase(user));
      } on FirebaseException catch (e) {
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      } catch (e) {
        return AuthResult.failure("Email update failed. Please try again.");
      }
    } else {
      return AuthResult.failure("Anonymous users cannot update email directly.");
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

  Future<AuthResult<void>> signOutMethod() async {
    try {
      // It's safe to call signOut on both. GoogleSignIn will do nothing if not signed in.
      await _googleSignIn.signOut();
      await _auth.signOut();
      return AuthResult.success(null);
    } on Exception {
      return AuthResult.failure("Logout failed. Please try again.");
    }
  }

  Future<AuthResult<void>> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure("No user is currently signed in.");
      }
      String uid = user.uid;
      await Future.wait([
        DatabaseService(uid: uid).deleteUser(),
        user.delete(),
      ]);

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("Account deletion failed. Please try again later.");
    }
  }

  Future<UserCredential> _googleSignInSupport(
    GoogleSignInAccount account,
  ) async {
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(
      credential,
    );
  }

  Future<AuthResult<MathUser?>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return AuthResult.failure("Google Sign-In cancelled.");
      }

      final UserCredential userCredential = await _googleSignInSupport(account);
      final User? user = userCredential.user;

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await DatabaseService(
          uid: user!.uid,
        ).addUserData("Player", gameRecordInitialization);
      }

      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    } catch (e) {
      return AuthResult.failure("An error occurred during Google Sign-In.");
    }
  }

  Future<AuthResult<MathUser?>> attemptSilentSignIn() async {
    try {
      final GoogleSignInAccount? account =
          await _googleSignIn.signInSilently();
      if (account != null) {
        final UserCredential userCredential = await _googleSignInSupport(
          account,
        );

        return AuthResult.success(_userFromFireBase(userCredential.user));
      } else {
        return AuthResult.failure("No existing Google session found.");
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }    catch (e) {
  return AuthResult.failure("An error occurred during Google Sign-In.");
  }
  }

  String _mapErrorCodeToMessage(FirebaseException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found for this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Please enter a stronger password.";
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'operation-not-allowed':
        return "Sign-in method not enabled. Please contact support.";
      case 'network-request-failed':
        return "Network error. Please check your connection.";
      case "requires-recent-login":
        return "For security, please log in again before performing this action.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }
}
