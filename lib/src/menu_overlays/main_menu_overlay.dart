import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

class MainMenuOverllay extends MenuOverllay {
  MainMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _MainMenuOverllayState(game: game);
}

class _MainMenuOverllayState extends MenuOverllayState {
  _MainMenuOverllayState({required GameCore game}) : super(game: game);

  Column mainMenu(BuildContext context) {
    List<Widget> buttons = [
      button("NewGame", game.startNewGame),
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
      button("Quit", () => exit(0)),
    ];
    return menuGroup(buttons);
  }

  Column mainOptions(BuildContext context) {
    List<Widget> buttons = [
      button("NewGame", game.startNewGame),
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
