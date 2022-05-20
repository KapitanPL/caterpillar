import 'package:catterpillardream/src/game_core.dart';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

enum BaseViewType { MainMenu, Game }

abstract class BaseView {
  String currentRules = "";
  late final GameCore game;

  BaseView(this.game);

  void activate();
  void deactivate();

  void update(double t);
  void joypadChanged(double degrees, double distance);
  void render(Canvas c);

  Vector2 getHeadCenterPosition();
}
