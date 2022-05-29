import 'package:catterpillardream/src/menu_overlays/base_menu_overlay.dart';

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

  @override
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
        widget.game.gameState.setMenu(false);
        widget.game.pauseGame(false);
      }),
      button("Quit to main menu", widget.game.endGameAndBackToMain),
    ];
    return menuGroup(buttons);
  }
}
