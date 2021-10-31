import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'caterpillar.dart';

typedef ScoreCallback = void Function(int score);

class GameCore extends FlameGame with HasCollidables {
  GameCore({required this.scoreCallback}) {
    Caterpillar cat = createNewCaterpillar();
    final Set<int> colors = {1, 2, 3, 4};
    cat.initBodyRandomCount(4, colors);
    caterpillars[cat.id()] = cat;
    _playerId = cat.id();
  }
  double _direction = 0;
  final ScoreCallback scoreCallback;
  int _lastAssociatedId = -1;
  int _playerId = -1;
  double _fps = 0;
  Map<int, Caterpillar> caterpillars = {};

  void joypadChanged(double degrees, double distance) {
    _direction = degrees;
    caterpillars[_playerId]!.directionChanged(_direction, distance);
  }

  Caterpillar createNewCaterpillar() {
    _lastAssociatedId++;
    return Caterpillar(_lastAssociatedId);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fps = 1 / dt;
    caterpillars.forEach((key, value) {
      value.update(dt);
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    TextPainter tp = TextPainter(
        text: TextSpan(
            style: const TextStyle(color: Colors.amber),
            text: "FPS ${_fps.toStringAsFixed(2)}"),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, const Offset(0, 0));
    caterpillars.forEach((key, value) {
      value.paint(canvas);
    });
  }
}
