import 'dart:io';
import 'base_menu_overlay.dart';

import 'package:catterpillardream/src/game_core.dart';
import 'package:flutter/material.dart';

class MainMenuOverllay extends MenuOverllay {
  MainMenuOverllay({required Key key, required GameCore game})
      : super(key: key, game: game);

  @override
  MenuOverllayState createState() => _MainMenuOverllayState();
}

class _MainMenuOverllayState extends MenuOverllayState {
  _MainMenuOverllayState() : super();

  @override
  Column mainMenu(BuildContext context) {
    List<Widget> buttons = [
      button("Play!", widget.game.startNewGame),
      button(
          "Select new game",
          () => {
                setState(() {
                  menuContext = MenuContext.NewGameMenu;
                })
              }),
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

  @override
  Column newGameMenu(BuildContext context) {
    List<Widget> buttons = [
      button("Zen", () {}),
      button("Duel", () {}),
      button("Story", () {}),
      button("Total zen", () {}),
      button("Custom", () {}),
      const SizedBox(height: 10),
      button(
          "Batk to Main",
          (() => setState(() {
                menuContext = MenuContext.Root;
              }))),
    ];
    return menuGroup(buttons);
  }
}
