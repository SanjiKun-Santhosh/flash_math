import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

class Template extends StatelessWidget {
  final Widget child;

  const Template({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: Colors.brown[50],
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Image.asset(
            ImageGallery().secondaryBG,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child!),
        ],
      ),
    );
  }
}
