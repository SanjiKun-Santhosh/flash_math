import 'package:flash_math/screens/home.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ImagePicker _imagePicker=ImagePicker();
  final _formKey=GlobalKey<FormState>();
  String _profileImagePath=ImageGallery().profilePicture;
  Future<void>_pickImage(ImageSource source) async{
    final XFile? pickedImage=await _imagePicker.pickImage(source: source);
    if(pickedImage!=null){
_profileImagePath=pickedImage.path;
    }
  }
  @override
  Widget build(BuildContext context) {
    final mathUser = Provider.of<MathUser?>(context);
    return Scaffold(backgroundColor:Colors.transparent,body: SafeArea(child: Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(flex:3,child: InkWell(
            splashColor: Colors.black,
            radius: 100,
            onTap: (){
             setState(() {
               _pickImage(ImageSource.gallery);
             });
            },
            child: CircleAvatar(
              backgroundColor: Colors.red,
              foregroundColor: Colors.black,
              radius: 100,
              backgroundImage: AssetImage(_profileImagePath),

            ),
          )),
          SizedBox(height: 30,),
          Flexible(flex:5,child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(20),
            child: Form(key:_formKey,
                child: Column(children: [
              SizedBox(height: 20,),
              TextFormField(decoration: AppDecoration().textDecoration,initialValue: "User name",),
                  SizedBox(height: 30,),
                  TextFormField(decoration: AppDecoration().textDecoration,initialValue: "Email",),
                  SizedBox(height: 30,),
                  TextFormField(decoration: AppDecoration().textDecoration,initialValue: "Password",),
                  SizedBox(height: 30,),
                  ElevatedButton.icon(onPressed: (){
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                      icon: Icon(Icons.save_alt_rounded),
                      label: Text("Save changes"),
                 )
            
            ],)),
          ))
        ],
      ),
    )),);
  }
}
