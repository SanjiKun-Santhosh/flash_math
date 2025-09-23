import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth.dart';
import '../shared/constants.dart';
import 'loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _loading = false;
  final Auth _auth = Auth();
  final formKey = GlobalKey<FormState>();
  late String _currentEmail;
  late String _currentPassword;
  final RegExp _regex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@!#%^&*.,:"-=+;$~])',
  );

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                "Register",
                style: TextStyle(
                  fontFamily: CustomFontStyle().primaryFont,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        textAlign: TextAlign.center,
                        "Welcome New User!",
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: CustomFontStyle().primaryFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                        initialValue: "Email",
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
                        decoration: AppDecoration().textDecoration,
                      ),

                      const SizedBox(height: 50),
                      TextFormField(
                        initialValue: "Password",
                        obscureText: true,
                        obscuringCharacter: "*",
                        onChanged: (val) {
                          setState(() {
                            _currentPassword = val;
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "The Password is empty";
                          } else {
                            if (!_regex.hasMatch(val)) {
                              return ErrorMsg().passwordErrorMsg;
                            } else {
                              return null;
                            }
                          }
                        },
                        decoration: AppDecoration().textDecoration,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _loading = !_loading;
                            });
                            dynamic result = await _auth
                                .registerWithEmailAndPassword(
                                  _currentEmail,
                                  _currentPassword,
                                );
                            if (!mounted) return;
                            setState(() {
                              _loading = false;
                              if (result.isFailure) {
                                ErrorHandling().showError(
                                  context,
                                  result.errorMsg,
                                );
                              }
                            });
                          }
                        },

                        label: Text(
                          "Register",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: CustomFontStyle().primaryFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          Icons.login_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
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
                              "Login",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontFamily: CustomFontStyle().primaryFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: FaIcon(FontAwesomeIcons.facebook),
                          //   iconSize: 40,
                          // ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: FaIcon(FontAwesomeIcons.instagram),
                          //   iconSize: 40,
                          // ),
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                _loading = true;
                              });
                              dynamic result = await _auth.signInWithGoogle();
                              if (!mounted) return;
                              setState(() {
                                _loading = false;
                                if (result.isFailure) {
                                  ErrorHandling().showError(
                                    context,
                                    result.errorMsg,
                                  );
                                }
                              });
                            },
                            icon: FaIcon(FontAwesomeIcons.google),
                            iconSize: 40,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
