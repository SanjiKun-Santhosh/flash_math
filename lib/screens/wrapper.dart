import 'package:flash_math/screens/template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/user_record.dart';
import '../services/database.dart';
import 'authenticate.dart';
import 'home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final mathUser = Provider.of<MathUser?>(context);
    if (mathUser == null) {
      return const Template(child: Authenticate());
    } else {
      return const Template(child: Home());
    }
  }
}
