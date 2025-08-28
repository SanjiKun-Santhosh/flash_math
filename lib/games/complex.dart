import 'dart:math';

import 'package:flash_math/games/addition.dart';
import 'package:flash_math/games/substraction.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_record.dart';
class Complex extends StatefulWidget {
  const Complex({super.key});

  @override
  State<Complex> createState() => _ComplexState();
}

class _ComplexState extends State<Complex> {
    @override
  Widget build(BuildContext context) {
return const Template(child: Loading());
  }
}
