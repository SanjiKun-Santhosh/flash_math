import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class Confetti extends StatefulWidget {
  final bool isPlaying;
  const Confetti({super.key, required this.isPlaying});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> {
  late ConfettiController _controllerBottomCenter;
  bool isPlaying=false;
  @override
  void initState() {
    super.initState();
    _controllerBottomCenter = ConfettiController(
      duration: const Duration(seconds: 10),
    );
  }


  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    super.dispose();
  }
  Widget control(){
    setState(() {
      _controllerBottomCenter.play();
    });
    return Align(alignment:Alignment.topCenter,
        child:   ConfettiWidget(
          confettiController: _controllerBottomCenter,
          blastDirection: -pi / 2,
          emissionFrequency: 0.01,
          numberOfParticles: 50,
          maxBlastForce: 100,
          minBlastForce: 80,
          gravity: 0.3,
        ));
  }
  @override
  Widget build(BuildContext context) {
    isPlaying=widget.isPlaying;
    return isPlaying ? control()
    : Container();
  }
}
