import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

enum MainMenuContext {
  MainMenu,
  MainOptions,
  Controls,
}

class MainMenuOverllay extends MenuOverllay {
  MainMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _MainMenuOverllayState(game: game);
}

class _MainMenuOverllayState extends MenuOverllayState {
  MainMenuContext _context = MainMenuContext.MainMenu;
  _MainMenuOverllayState({required GameCore game}) : super(game: game);

  Column mainMenu(BuildContext context) {
    List<Widget> buttons = [
      button("NewGame", game.startNewGame),
      button(
          "Options",
          () => {
                setState(() {
                  _context = MainMenuContext.MainOptions;
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
                  _context = MainMenuContext.MainMenu;
                })
              }),
    ];
    return menuGroup(buttons);
  }

  Column controls(BuildContext context) {
    List<Widget> buttons = [];
    return menuGroup(buttons);
  }

  @override
  Widget build(BuildContext context) {
    switch (_context) {
      case MainMenuContext.MainMenu:
        {
          return mainMenu(context);
        }
      case MainMenuContext.MainOptions:
        {
          return mainOptions(context);
        }
      case MainMenuContext.Controls:
        {
          return controls(context);
        }
    }
  }
}
