import 'game_core.dart';
import 'globals.dart';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PrimitiveTypeWrapper<T> {
  late T val;
  PrimitiveTypeWrapper(this.val);
}

enum BaseViewType {
  MainMenu,
  Game,
}

abstract class BaseView {
  late final GameCore game;

  BaseView(this.game);

  void activate();
  void deactivate();

  void update(double t);
  void joypadChanged(double degrees, double distance);
  void render(Canvas c);
}
