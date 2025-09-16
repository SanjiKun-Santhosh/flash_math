import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_math/shared/authresult.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'database.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;
  final String _serverClientId =
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

  Future<AuthResult<MathUser?>> loginInAnonymously() async {
    try {
      UserCredential credential = await _auth.signInAnonymously();
      User? user = credential.user;
      await DatabaseService(
        uid: user!.uid,
      ).addUserData("Player", gameRecordInitialization);
      return AuthResult.success(_userFromFireBase(user));
    }on FirebaseException catch (e){
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }
    catch (e) {
      return AuthResult.failure("Unexpected error occurred: $e");
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
    }on FirebaseException catch (e){
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }
    catch (e) {
      return AuthResult.failure("Unexpected error occurred: $e");
    }
  }

  Future<AuthResult<MathUser?>> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      return AuthResult.success(_userFromFireBase(user));
    } on FirebaseException catch (e){
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }
    catch (e) {
      return AuthResult.failure("Unexpected error occurred: $e");
    }
  }

  Future <AuthResult<MathUser?>> registerWithEmailAndPassword(String email, String password) async {
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
    } on FirebaseException catch (e){
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }
    catch (e) {
      return AuthResult.failure("Unexpected error occurred: $e");
    }
  }

  Future <AuthResult<dynamic>> updateName(String name) async {
    try {
      User? user = _auth.currentUser;
      dynamic result = await DatabaseService(uid: user!.uid).updateName(name);
      return AuthResult.success(result);
    } on FirebaseException catch (e){
      return AuthResult.failure(_mapErrorCodeToMessage(e));
    }
    catch (e) {
      return AuthResult.failure("Unexpected error occurred: $e");
    }
  }

  Future <AuthResult<MathUser?>> updateUserEmailAndPassword(String email, String password) async {
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
      } on FirebaseException catch (e){
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      }
      catch (e) {
        return AuthResult.failure("Unexpected error occurred: $e");
      }
    } else {
      return linkAnonymousWithCredentials(email, password);
    }
  }

  Future <AuthResult<MathUser?>> updatePassword(String password) async {
    if (await checkAnonymousUser() == false) {
      try {
        User? user = _auth.currentUser;
        if (password.isNotEmpty) {
          await user!.updatePassword(password);
        }
         return AuthResult.success(_userFromFireBase(user));
      } on FirebaseException catch (e){
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      }
      catch (e) {
        return AuthResult.failure("Unexpected error occurred: $e");
      }
    }else{
      return AuthResult.failure("Something wrong! cannot update password");
    }
  }

  Future <AuthResult<MathUser?>> updateEmail(String email) async {
    if (await checkAnonymousUser() == false) {
      try {
        User? user = _auth.currentUser;
        String? currentEmail = user?.email;
        if (email != currentEmail && email.isNotEmpty) {
          await user!.verifyBeforeUpdateEmail(email);
        }
        return AuthResult.success(_userFromFireBase(user));
      } on FirebaseException catch (e){
        return AuthResult.failure(_mapErrorCodeToMessage(e));
      }
      catch (e) {
        return AuthResult.failure("Unexpected error occurred: $e");
      }
    }else{
      return AuthResult.failure("Something wrong! cannot update email");
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
      if (_isGoogleSignInInitialized) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      return AuthResult.success(null);
    } on Exception catch (e){
      return AuthResult.failure("Unexpected error occurred: $e");

    }
  }

  Future<AuthResult<void>> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _isGoogleSignInInitialized = true;
      return AuthResult.success(null);
    }  on Exception catch (e){
      return AuthResult.failure("Unexpected error occurred: $e");

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
    return userCredential;
  }

  Future<AuthResult<MathUser?>> signInWithGoogle() async {
    _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      final UserCredential userCredential = await _googleSignInSupport(account);
      final User? user = userCredential.user;
      final DatabaseService dbService = DatabaseService(uid: user!.uid);
      final userData = await dbService.userData.first.timeout(
        Duration(seconds: 5),
        onTimeout: null,
      );
      if (userData.gameRecord == null || userData.gameRecord!.isEmpty) {
        await DatabaseService(
          uid: user.uid,
        ).addUserData("Player", gameRecordInitialization);
      }

      return AuthResult.success(_userFromFireBase(user));
    } on GoogleSignInException catch (e) {
      return AuthResult.failure("Google Sign-In failed: ${e.code.name}");
    }
    catch (e) {
      return AuthResult.failure("Google Sign-In failed ${e.toString()}");
    }
  }

  Future<AuthResult<MathUser?>> attemptSilentSignIn() async {
    await _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount? account = await _googleSignIn
          .attemptLightweightAuthentication();
      if (account != null) {
        final UserCredential userCredential = await _googleSignInSupport(
          account,
        );

        return  AuthResult.success(_userFromFireBase(userCredential.user));
      } else {
        return AuthResult.failure("Google Sign-In failed");
      }
    } on GoogleSignInException catch (e) {
      return AuthResult.failure(e.code.name);
    }catch (e) {
      return AuthResult.failure("Google Sign-In failed ${e.toString()}");
    }
  }

  String _mapErrorCodeToMessage(FirebaseException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found for this email";
      case 'wrong-password':
        return "Invalid password";
      case 'email-already-in-use':
        return "This email is already registered";
      case 'weak-password':
        return "Please enter a strong password";
      default:
        return e.message ?? "Authentication failed";
    }
  }
}
