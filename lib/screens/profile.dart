import 'dart:io';

import 'package:flash_math/services/auth.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/user_record.dart';

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
  String _email = "";
  String _name="";
  TextEditingController _textEditingController=TextEditingController();

  Future<void> getData() async {
    _email = await _auth.getEmail();

    setState(() {
      _textEditingController = TextEditingController(text: _email.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage == null) return;
    setState(() {
      _imageFile = File(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService service = DatabaseService(
      uid: Provider.of<MathUser?>(context)!.uid,
    );
    return Scaffold(
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
                  radius: 100,
                  onTap: () {
                    setState(() {
                      _pickImage(ImageSource.gallery);
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    radius: 100,
                    backgroundImage: (_imageFile == null)
                        ? AssetImage(ImageGallery().profilePicture)
                        : FileImage(_imageFile!) as ImageProvider,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: AppDecoration().textDecoration,
                          initialValue: "User name",
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          decoration: AppDecoration().textDecoration,
                          controller: _textEditingController,
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          decoration: AppDecoration().textDecoration,
                          initialValue: "Password",
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.save_alt_rounded),
                          label: Text("Save changes"),
                        ),
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
