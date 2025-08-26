import 'package:flash_math/models/user.dart';
import 'package:flash_math/screens/custom_sheets.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  final Function() toggleView;

  const Login({super.key, required this.toggleView});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Auth _auth = Auth();
  final formKey = GlobalKey<FormState>();
  String _currentEmail = ""; // Initialize to empty
  String _currentPassword = ""; // Initialize to empty
  final RegExp _regex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@!#%^&*.,:"-=+;\$\~])',
  );
  bool _loading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.attemptSilentSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              actionsPadding: EdgeInsets.all(10),
              title: Text(
                "Flash Math",
                softWrap: true,
                style: TextStyle(
                  fontFamily: CustomFontStyle().primaryFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Text(
                      textAlign: TextAlign.center,
                      "Welcome to the Login!",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: CustomFontStyle().primaryFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          _currentEmail = val;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "The email is empty";
                        } else {
                          if (val.contains("@") &&
                              val.contains(".") &&
                              val.length > 5) {
                            return null;
                          } else {
                            return "The email is incorrect";
                          }
                        }
                      },
                      decoration: AppDecoration().textDecoration.copyWith(
                        hintText: "Email",
                      ),
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      obscureText: true,
                      obscuringCharacter: "*",
                      onChanged: (val) {
                        setState(() {
                          _currentPassword = val;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "The Password is empty";
                        } else {
                          if (!_regex.hasMatch(val)) {
                            return ErrorMsg().passwordErrorMsg;
                          } else {
                            return null;
                          }
                        }
                      },
                      decoration: AppDecoration().textDecoration.copyWith(
                        hintText: "Password",
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            _loading = true;
                          });
                          dynamic result = await _auth
                              .loginWithEmailAndPassword(
                                _currentEmail,
                                _currentPassword,
                              );

                          if (!mounted) return;

                          setState(() {
                            _loading = false;
                            if (result == null ||
                                result.toString().contains("error")) {
                              CustomSheets().showLoginErrorDialog(context);
                            } else {}
                          });
                        }
                      },
                      label: Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: CustomFontStyle().primaryFont,
                        ),
                      ),
                      icon: Icon(
                        Icons.login_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: CustomFontStyle().primaryFont,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.toggleView();
                            });
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 20,
                              fontFamily: CustomFontStyle().primaryFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            // TODO: Implement Facebook login
                          },
                          icon: FaIcon(FontAwesomeIcons.facebook),
                          iconSize: 40,
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement Instagram login
                          },
                          icon: FaIcon(FontAwesomeIcons.instagram),
                          iconSize: 40,
                        ),
                        IconButton(
                          onPressed: () async{
                            dynamic result = await _auth.signInWithGoogle();
                         if (!mounted) return;
                            setState(() {
                              if (result == null ||
                                  result.toString().contains("error")) {
                                CustomSheets().showLoginErrorDialog(context);
                              } else {}
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.google),
                          iconSize: 40,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
  }
}
