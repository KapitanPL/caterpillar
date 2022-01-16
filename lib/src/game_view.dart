import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:catterpillardream/src/game_core.dart';

import 'base_view.dart';

import 'caterpillar.dart';

class GameView extends BaseView {
  GameView(GameCore game) : super(game);

  double _direction = 0;

  PrimitiveTypeWrapper<int> lastAssociatedId = PrimitiveTypeWrapper<int>(-1);
  int _playerId = -1;
  double _fps = 0;
  final Set<int> _colors = {1, 2, 3, 4};
  Map<int, Caterpillar> caterpillars = {};

  @override
  void activate() {
    Caterpillar cat =
        game.createNewCaterpillar(lastAssociatedId, Vector2(100, 100));
    cat.initBodyRandomCount(10, _colors);
    caterpillars[cat.id()] = cat;
    _playerId = cat.id();

    for (var i = 0; i < 10; ++i) {
      game.addFood(_colors);
    }
  }

  @override
  void update(double t) {
    _fps = 1 / t;
    caterpillars.forEach((key, value) {
      value.update(t);
    });
  }

  @override
  void render(Canvas c) {
    TextPainter tp = TextPainter(
        text: TextSpan(
            style: const TextStyle(color: Colors.amber),
            text: "FPS ${_fps.toStringAsFixed(2)}"),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, const Offset(0, 0));
    caterpillars.forEach((key, value) {
      value.render(c);
    });
  }

  @override
  void joypadChanged(double degrees, double distance) {
    _direction = degrees;
    print("direction $_direction");
    if (caterpillars.keys.contains(_playerId)) {
      caterpillars[_playerId]!.directionChanged(_direction, distance);
    }
  }

  @override
  void deactivate() {}
}
