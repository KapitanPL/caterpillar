import 'dart:io';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

class MainMenuOverllay extends StatelessWidget {
  final GameCore game;
  const MainMenuOverllay({required Key key, required this.game})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IntrinsicWidth(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  child: const Text("New Game"),
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text("Options"),
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text("Quit"),
                  onPressed: () => exit(0),
                ),
              ]),
        ),
      ])
    ]);
    ;
  }
}
