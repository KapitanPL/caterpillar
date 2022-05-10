import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

class InGameMenuOverllay extends MenuOverllay {
  InGameMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _InGameMenuOverllayState(game: game);
}

class _InGameMenuOverllayState extends MenuOverllayState {
  MenuContext menuContext = MenuContext.Root;
  _InGameMenuOverllayState({required GameCore game}) : super(game: game);

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
        game.pauseGame(false);
      }),
    ];
    return menuGroup(buttons);
  }

  Column mainOptions(BuildContext context) {
    List<Widget> buttons = [
      button(
          "Back to Main",
          () => {
                setState(() {
                  menuContext = MenuContext.Root;
                })
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
    }
  }
}
