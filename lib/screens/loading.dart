import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitDualRing(color: Colors.white,
        size: 60,),
        SizedBox(height: 50,),
        Text("Loading, please wait !!!",style: TextStyle(fontFamily: "Bitcount" ,fontWeight:FontWeight.bold,fontSize: 20),)
      ],
    );
  }
}
