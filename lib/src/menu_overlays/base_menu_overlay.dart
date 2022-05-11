import 'dart:io' show Platform;
import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';
import 'package:catterpillardream/src/gameSettings/ingame_settings.dart';

import 'package:catterpillardream/src/menu_overlays/widgets/button_selectors.dart';

typedef ButtonCallback = void Function();

enum MenuContext {
  Root,
  Options,
  Controls,
}

class MenuOverllay extends StatefulWidget {
  final GameCore game;
  MenuOverllay({required Key key, required this.game}) : super(key: key);

  @override
  MenuOverllayState createState() => MenuOverllayState(game: game);
}

class MenuOverllayState extends State<MenuOverllay> {
  MenuContext menuContext = MenuContext.Root;
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

  Column controls(BuildContext context) {
    List<Widget> buttons = [];
    // controls
    bool isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    String tapPointName = isDesktop ? "Mouse" : "Touch";
    buttons.addAll([
      const Text("Controls: ",
          style: TextStyle(
            color: Colors.amber,
          )),
      RadioButtonList<Controls>(
        key: const Key("RadioControls"),
        captions: ["Joypad", tapPointName],
        values: const <Controls>{Controls.joypad, Controls.tapPoint},
        initValue: Controls.joypad,
        onButtonChanged: (Controls value) => setState(() {
          GameSettings.controls = value;
        }),
      )
    ]);
    if (GameSettings.controls == Controls.joypad) {
      buttons.addAll([
        const Text("Joypad position: ",
            style: TextStyle(
              color: Colors.amber,
            )),
        RadioButtonList<JoypadPosition>(
          key: const Key("RadioControlsPosition"),
          captions: const ["Left", "Right"],
          values: const <JoypadPosition>{
            JoypadPosition.left,
            JoypadPosition.right
          },
          initValue: JoypadPosition.right,
          onButtonChanged: (JoypadPosition value) {
            widget.game.joypadPositionChanged?.call(value);
          },
        )
      ]);
    }
    // back
    buttons.add(button(
        "Back to Main",
        () => {
              setState(() {
                menuContext = MenuContext.Root;
              })
            }));
    return menuGroup(buttons);
  }
}
