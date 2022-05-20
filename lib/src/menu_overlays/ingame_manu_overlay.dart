import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

class InGameMenuOverllay extends MenuOverllay {
  InGameMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _InGameMenuOverllayState();
}

class _InGameMenuOverllayState extends MenuOverllayState {
  _InGameMenuOverllayState() : super();

  Column mainMenu(BuildContext context) {
    List<Widget> buttons = [
      button(
          "Options",
          () => {
                setState(() {
                  menuContext = MenuContext.Options;
                })
              }),
      button(
          "Controls",
          () => {
                setState(() {
                  menuContext = MenuContext.Controls;
                })
              }),
      button("Back to game", () {
        widget.game.pauseGame(false);
      }),
    ];
    return menuGroup(buttons);
  }

  @override
  Widget build(BuildContext context) {
    switch (menuContext) {
      case MenuContext.Root:
        {
          return mainMenu(context);
        }
      case MenuContext.Options:
        {
          return mainOptions(context);
        }
      case MenuContext.Controls:
        {
          return controls(context);
        }
      case MenuContext.Rules:
        {
          return rulesSection(context);
        }
    }
  }
}
