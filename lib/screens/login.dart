import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_math/screens/custom_sheets.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  final Function() toggleView;

  const Login({super.key, required this.toggleView});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Auth _auth = Auth();
  final formKey = GlobalKey<FormState>();
  String _currentEmail = "";
  String _currentPassword = "";
  final RegExp _regex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@!#%^&*.,:"-=+;\$\~])',
  );
  bool _loading = false;

  @override
  void initState() {
    _auth.attemptSilentSignIn();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              actionsPadding: EdgeInsets.all(10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _animation,
                    child: Icon(
                      Icons.flash_on_outlined,
                      color: Colors.amber,
                      size: 40,
                      weight: 20,
                    ),
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        "Flash Math",
                        curve: Curves.bounceInOut,
                        textStyle: TextStyle(
                          fontFamily: CustomFontStyle().primaryFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              child: Container(
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
                      const SizedBox(height: 50),
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
                      const SizedBox(height: 50),
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
                      const SizedBox(height: 50),
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
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: CustomFontStyle().primaryFont,
                          ),
                        ),
                        icon: Icon(
                          Icons.login_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                          });
                          dynamic result = _auth.loginInAnonymously();
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
                        child: const Text("Try the game as GUEST"),
                      ),
                     const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
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
                                color: Colors.yellow,
                                fontSize: 20,
                                fontFamily: CustomFontStyle().primaryFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const  SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // IconButton(
                          //   onPressed: () {
                          //     // TODO: Implement Facebook login
                          //   },
                          //   icon: FaIcon(FontAwesomeIcons.facebook),
                          //   iconSize: 40,
                          // ),
                          // IconButton(
                          //   onPressed: () {
                          //     // TODO: Implement Instagram login
                          //   },
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
                     const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
