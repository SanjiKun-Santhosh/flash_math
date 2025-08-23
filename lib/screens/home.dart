import 'package:flash_math/screens/listOfGames.dart';
import 'package:flash_math/screens/profile.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final Auth auth=Auth();
    return Scaffold(
        appBar:AppBar(centerTitle:true,backgroundColor: Colors.transparent,actions:<Widget> [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
              ElevatedButton.icon(onPressed: (){
                setState(() {
                   Navigator.pushNamed(context, "/userProfile");
                });
              }, icon:Icon(Icons.person_2_outlined),label: Text("Profile")),
              SizedBox(width: 130,),
              ElevatedButton.icon(onPressed: ()async{
                await auth.signOut();
              },icon: Icon(Icons.logout_rounded), label: Text("Logout")),

              SizedBox(width: 30,)
            ],
          )

        ],),
        backgroundColor:Colors.transparent,
      body: Container(padding: EdgeInsets.fromLTRB(15,15,15,0),
      margin: EdgeInsets.all(40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListOfGames(fontSize:30),
        ],
      ),

      ));
  }
}
