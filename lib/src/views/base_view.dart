import 'package:catterpillardream/src/game_core.dart';

import 'package:flutter/material.dart';

enum BaseViewType { MainMenu, Game }

abstract class BaseView {
  late final GameCore game;

  BaseView(this.game);

  void activate();
  void deactivate();

  void update(double t);
  void joypadChanged(double degrees, double distance);
  void render(Canvas c);
}
