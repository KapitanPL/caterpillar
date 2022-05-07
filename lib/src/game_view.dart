import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:catterpillardream/src/game_core.dart';

import 'base_view.dart';
import 'caterpillar.dart';
import 'globals.dart';
import 'rules.dart';

class GameView extends BaseView {
  bool renderGrid = false;
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
      game.addFood(colors: _colors);
    }

    double wallThickness = 10;
    List<Vector2> points = [
      Vector2(wallThickness, wallThickness),
      Vector2(game.screenSize.x - wallThickness, wallThickness),
      Vector2(
          game.screenSize.x - wallThickness, game.screenSize.y - wallThickness),
      Vector2(wallThickness, game.screenSize.y - wallThickness),
    ];

    game.addWall(points: points, close: true);

    Rules rules = Rules();
    rules.canColideWithSelf = false;
    RulesProvider.rules = rules;
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

    if (renderGrid) {
      Paint paint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 1;
      double x = 100;
      while (x < game.screenSize.x) {
        c.drawLine(Offset(x, 0), Offset(x, game.screenSize.y), paint);
        x += 100;
      }
      double y = 100;
      while (y < game.screenSize.y) {
        c.drawLine(Offset(0, y), Offset(game.screenSize.x, y), paint);
        y += 100;
      }
    }
  }

  @override
  void joypadChanged(double degrees, double distance) {
    _direction = degrees;
    if (caterpillars.keys.contains(_playerId)) {
      caterpillars[_playerId]!.directionChanged(_direction, distance);
    }
  }

  @override
  void deactivate() {}
}
