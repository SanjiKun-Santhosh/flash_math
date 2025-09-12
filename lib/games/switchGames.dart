import 'package:flash_math/games/levels.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchGames extends StatefulWidget {
  final String gameChosen;

  const SwitchGames({super.key, required this.gameChosen});

  @override
  State<SwitchGames> createState() => _SwitchGamesState();
}

class _SwitchGamesState extends State<SwitchGames> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRecord = context.read<UserRecord?>();
      if (userRecord != null) {
        print("object ${userRecord.name}");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final userRecord = context.watch<UserRecord?>();
    if (userRecord != null) {
      switch (widget.gameChosen) {
        case "Addition":
          return Levels(gameType: widget.gameChosen);
        case "Substraction":
          return Levels(gameType: widget.gameChosen);
        case "Complex":
          return Levels(gameType: widget.gameChosen);
        case "Flash":
          return Levels(gameType: widget.gameChosen);
        default:
          return const Template(child: Loading());
      }
    } else {
      return const Template(child: Loading());
    }
  }
}
