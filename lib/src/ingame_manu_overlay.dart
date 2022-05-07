import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

enum InGameMenuContext {
  MainMenu,
  MainOptions,
  Controls,
}

class InGameMenuOverllay extends MenuOverllay {
  InGameMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _InGameMenuOverllayState(game: game);
}

class _InGameMenuOverllayState extends MenuOverllayState {
  InGameMenuContext _context = InGameMenuContext.MainMenu;
  _InGameMenuOverllayState({required GameCore game}) : super(game: game);

  Column mainMenu(BuildContext context) {
    List<Widget> buttons = [
      button(
          "Options",
          () => {
                setState(() {
                  _context = InGameMenuContext.MainOptions;
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
                  _context = InGameMenuContext.MainMenu;
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
      case InGameMenuContext.MainMenu:
        {
          return mainMenu(context);
        }
      case InGameMenuContext.MainOptions:
        {
          return mainOptions(context);
        }
      case InGameMenuContext.Controls:
        {
          return controls(context);
        }
    }
  }
}
