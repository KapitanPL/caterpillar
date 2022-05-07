import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

typedef ButtonCallback = void Function();

class MenuOverllay extends StatefulWidget {
  final GameCore game;
  MenuOverllay({required Key key, required this.game}) : super(key: key);

  @override
  MenuOverllayState createState() => MenuOverllayState(game: game);
}

class MenuOverllayState extends State<MenuOverllay> {
  final GameCore game;
  MenuOverllayState({required this.game});

  ElevatedButton button(String text, ButtonCallback callback) {
    return ElevatedButton(
      child: Text(text),
      onPressed: () {
        callback();
      },
    );
  }

  Column menuGroup(List<Widget> widgets) {
    List<Widget> children = [];
    for (var w in widgets) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 10));
      }
      children.add(w);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IntrinsicWidth(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children),
        ),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return menuGroup([]);
  }
}
