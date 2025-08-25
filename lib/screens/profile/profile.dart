import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore_platform_interface/src/get_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/profile/profile_support.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final Auth _auth = Auth();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  late Map<String, String> gameRecord;
  late String _newName = _textNameController.text;
  late String _newEmail = _textEmailController.text;
  String _newPassword = "";
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textNameController = TextEditingController();
  final RegExp _regex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@!#%^&*.,:"-=+;\$\~])',
  );
  bool _loading = false;
  bool _checkBox = false;
  bool _valueChanged = false;
final RecordBottomSheet recordBottomSheet=RecordBottomSheet();
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _textEmailController.dispose();
    _textNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userRecord = context.watch<UserRecord?>();
    if (userRecord != null) {
      if (userRecord.name.isEmpty) {
        _textNameController.text = "Player";
      } else {
        _textNameController.text = userRecord.name;
      }
      gameRecord = userRecord.gameRecord ?? {};
    }
    _auth.getEmail().then((email) {
      _textEmailController.text = email ?? '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage == null) return;
    setState(() => _imageFile = File(pickedImage.path));
  }

  @override
  Widget build(BuildContext context) {
    final mathUser = context.watch<MathUser?>();
    final userRecord = context.watch<UserRecord?>();
    Map<String, String>? gameRecord = userRecord?.gameRecord;
       if (mathUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _loading
        ? Template(child: Loading())
        : Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        splashColor: Colors.black,
                        radius: 90,
                        onTap: () {
                          setState(() {
                            _pickImage(ImageSource.gallery);
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,
                          radius: 90,
                          backgroundImage: (_imageFile == null)
                              ? AssetImage(ImageGallery().profilePicture)
                              : FileImage(_imageFile!) as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.all(10),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: AppDecoration().textDecoration,
                                controller: _textNameController,
                                onChanged: ((val) {
                                  setState(() {
                                    _newName = val;
                                    _valueChanged = true;
                                  });
                                }),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                decoration: AppDecoration().textDecoration,
                                controller: _textEmailController,
                                onChanged: ((val) {
                                  setState(() {
                                    _newEmail = val;
                                    _valueChanged = true;
                                  });
                                }),
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
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                decoration: AppDecoration().textDecoration,
                                initialValue: "Password",
                                obscuringCharacter: "*",
                                obscureText: !_checkBox,
                                onChanged: ((val) {
                                  setState(() {
                                    _newPassword = val;
                                    _valueChanged = true;
                                  });
                                }),
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
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Show password"),
                                  SizedBox(width: 5),
                                  Checkbox(
                                    value: _checkBox,
                                    onChanged: (val) {
                                      setState(() {
                                        _checkBox = !_checkBox;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              Row(mainAxisAlignment:MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(onPressed: (){
                                    recordBottomSheet.showCustomModalBottomSheet(context,gameRecord: gameRecord);

                                  }, child: Text("View record")),
                                  SizedBox(width: 10,),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_valueChanged) {
                                        if (!_formKey.currentState!.validate()) {
                                          return;
                                        }

                                        setState(() => _loading = true);

                                        try {
                                          await _auth.updateName(_newName);
                                          await _auth.updateUserEmailAndPassword(
                                            _newEmail,
                                            _newPassword,
                                          );

                                          if (!mounted) return;
                                          _valueChanged = false;
                                          Navigator.pop(context);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Failed to update profile: $e"),
                                            ));
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() => _loading = false);
                                          }
                                        }
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: Icon(Icons.save_alt_rounded),
                                    label: Text("Save changes"),
                                  )
                                ],)
                              ,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
