import 'dart:math';
import 'dart:ui';

import 'package:catterpillardream/src/game_view.dart';
import 'package:catterpillardream/src/main_menu_view.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'base_view.dart';
import 'caterpillar.dart';
import 'food.dart';

class GameCore extends FlameGame with HasCollidables {
  late Vector2 screenSize;
  final Map<BaseViewType, BaseView> _views = {};
  late BaseViewType _activeView;
  final Random _random = Random();
  GameCore();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _views[BaseViewType.Game] = GameView(this);
    _views[BaseViewType.MainMenu] = MainMenuView(this);
    var activeteView = BaseViewType.MainMenu;
    _activeView = activeteView;
    _views[activeteView]?.activate();
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
      collides = collidables[i].possiblyOverlapping(newFood);
      if (collides) {
        break;
      }
    }
    return collides;
  }

  void addFood(Set<int> colors) {
    FoodBase newFood = FoodBase(
        position: Vector2(_random.nextDouble() * screenSize.x,
            _random.nextDouble() * screenSize.y),
        type: colors.elementAt(_random.nextInt(colors.length)),
        eaten: () => addFood(colors));

    while (testFoodPositionCollides(newFood)) {
      newFood = FoodBase(
          position: Vector2(_random.nextDouble() * screenSize.x,
              _random.nextDouble() * screenSize.y),
          type: colors.elementAt(_random.nextInt(colors.length - 1)),
          eaten: () => addFood(colors));
    }
    add(newFood);
  }

  @override
  void update(double dt) {
    _views[_activeView]?.update(dt);
    super.update(dt);
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
