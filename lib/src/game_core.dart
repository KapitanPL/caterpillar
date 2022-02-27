import 'dart:math';
import 'dart:ui';

import 'package:catterpillardream/src/freespace_path_finding.dart';
import 'package:catterpillardream/src/game_view.dart';
import 'package:catterpillardream/src/main_menu_view.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'base_view.dart';
import 'caterpillar.dart';
import 'food.dart';
import 'walls.dart';

typedef ToggleJoypad = void Function(bool visible);

class GameCore extends FlameGame with HasCollidables {
  late Vector2 screenSize;
  final Map<BaseViewType, BaseView> _views = {};
  late BaseViewType _activeView;
  final Random _random = Random();
  late final ToggleJoypad _toggleJoypadCallback;
  GameCore(this._toggleJoypadCallback);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _views[BaseViewType.Game] = GameView(this);
    _views[BaseViewType.MainMenu] = MainMenuView(this);
    _activeView = BaseViewType.MainMenu;
    _views[_activeView]?.activate();
    _toggleJoypadCallback(_activeView == BaseViewType.Game);
  }

  void joypadChanged(double degrees, double distance) {
    _views[_activeView]?.joypadChanged(degrees, distance);
  }

  Caterpillar createNewCaterpillar(
      PrimitiveTypeWrapper<int> lastAssociatedId, Vector2 initPosition) {
    lastAssociatedId.val++;
    return Caterpillar(lastAssociatedId.val, this, initPosition);
  }

  bool testFoodPositionCollides(FoodBase newFood) {
    bool collides = true;
    for (var i = 0; i < collidables.length; ++i) {
      collides = collidables[i].possiblyOverlapping(newFood) &&
          CaterpillarPath.colision(collidables[i], newFood);
      if (collides) {
        break;
      }
    }
    return collides;
  }

  void addWall(
      {required List<Vector2> points,
      double thickness = 10,
      bool close = false}) {
    if (points.length > 1) {
      for (var i = 0; i < points.length - 1; ++i) {
        addWallBetweenPoints(start: points[i], end: points[i + 1]);
      }
      if (close && points.length > 2) {
        addWallBetweenPoints(start: points.last, end: points.first);
      }
    }
  }

  void addWallBetweenPoints(
      {required Vector2 start, required Vector2 end, double thickness = 10}) {
    Vector2 difference = end - start;
    Vector2 directionReal = Vector2(-difference.x, difference.y);
    double angle = directionReal.angleTo(Vector2(0, 1));
    if (directionReal.x < 0) {
      angle = 2 * pi - angle;
    }
    WallBase wall = WallBase(
        size: Vector2(thickness, difference.length + thickness),
        position: Vector2(start.x - thickness / 2, start.y - thickness / 2),
        angle: angle);
    add(wall);
  }

  void addFood({required Set<int> colors, Vector2? position}) {
    FoodBase newFood = FoodBase(
        position: position ??
            Vector2(_random.nextDouble() * screenSize.x,
                _random.nextDouble() * screenSize.y),
        type: colors.elementAt(_random.nextInt(colors.length)),
        eaten: () => addFood(colors: colors));

    while (testFoodPositionCollides(newFood) && position == null) {
      newFood = FoodBase(
          position: Vector2(_random.nextDouble() * screenSize.x,
              _random.nextDouble() * screenSize.y),
          type: colors.elementAt(_random.nextInt(colors.length - 1)),
          eaten: () => addFood(colors: colors));
    }
    add(newFood);
  }

  @override
  void update(double dt) {
    if (dt < 1) {
      _views[_activeView]?.update(dt);
      super.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    _views[_activeView]?.render(canvas);
    super.render(canvas);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    screenSize = canvasSize;
    super.onGameResize(screenSize);
  }
}
