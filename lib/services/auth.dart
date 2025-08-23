import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'database.dart';
///signout method is essential.
class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn=GoogleSignIn.instance;
  MathUser? _userFromFireBase(User? user) {
    return user != null ? MathUser(uid: user.uid) : null;
  }

  Stream<MathUser?> get mathUser {
    return _auth.authStateChanges().map(_userFromFireBase);
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
      await DatabaseService(uid: user!.uid).addUserData("John", {"addition":"0","substraction":"0"});


      return _userFromFireBase(user);
    } catch (e) {
      print(e.toString()); // TODO
      return null;
    }
  }
  Future <void> signOut()async{
    try{
      await _auth.signOut();
    }catch(e){
      print(e.toString()); // TODO
      return null;
    }
  }
  Future<dynamic> signInWithGoogle()async{
    try{
      final GoogleSignInAccount? googleUser=await _googleSignIn.

    }catch(e){

    }
  }
}
