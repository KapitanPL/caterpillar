import 'dart:math';
import 'dart:ui';

import 'package:catterpillardream/src/caterpillar_base.dart';
import 'package:catterpillardream/src/globals.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'game_view.dart';
import 'caterpillar.dart';
import 'game_core.dart';
import 'food.dart';

import 'freespace_path_finding.dart';

class MainMenuView extends GameView {
  late final GameCore _game;
  final Set<int> _colors = {1, 2, 3, 4};

  MainMenuView(GameCore game) : super(game) {
    _game = game;
  }

  @override
  void activate() {
    Caterpillar cat =
        game.createNewCaterpillar(lastAssociatedId, Vector2(0, 0));
    cat.initBodyRandomCount(10, _colors);
    cat.path = CaterpillarPath(cat.caterpillar[0].size.x, _game);
    caterpillars[cat.id()] = cat;

    /*Caterpillar cat2 =
        game.createNewCaterpillar(lastAssociatedId, _game.screenSize);
    cat2.initBodyRandomCount(10, _colors);
    cat2.path = CaterpillarPath(cat2.caterpillar[0].size.x, _game);
    caterpillars[cat2.id()] = cat2;

    Caterpillar cat3 = game.createNewCaterpillar(
        lastAssociatedId, Vector2(0, _game.screenSize.y));
    cat3.initBodyRandomCount(10, _colors);
    cat3.path = CaterpillarPath(cat3.caterpillar[0].size.x, _game);
    caterpillars[cat3.id()] = cat3;

    Caterpillar cat4 = game.createNewCaterpillar(
        lastAssociatedId, Vector2(_game.screenSize.x, 0));
    cat4.initBodyRandomCount(10, _colors);
    cat4.path = CaterpillarPath(cat4.caterpillar[0].size.x, _game);
    caterpillars[cat4.id()] = cat4;*/

    for (var i = 0; i < 10; ++i) {
      game.addFood(_colors);
    }
  }

  FoodBase? findClosestFood(CaterpillarHead head) {
    double minDistance = double.maxFinite;
    FoodBase? closestFood;
    for (var i = 0; i < game.collidables.length; ++i) {
      if (game.collidables[i] is FoodBase) {
        FoodBase food = game.collidables[i] as FoodBase;
        double distance = (food.distance(head));
        if (distance < minDistance) {
          minDistance = distance;
          closestFood = food;
        }
      }
    }
    return closestFood;
  }

  @override
  void update(double t) {
    const double toAngleConst = 360 / pi / 2;
    for (var catId = 0; catId <= lastAssociatedId.val; ++catId) {
      Caterpillar cat = caterpillars[catId]!;
      if (cat.caterpillar[0] is CaterpillarHead) {
        CaterpillarHead head = (cat.caterpillar[0] as CaterpillarHead);
        Vector2 headCenter = head.position + head.size / 2;

        FoodBase? closestFood = findClosestFood(head);
        if (closestFood != null) {
          cat.path!.clear();
          cat.path!.addPoint(headCenter);
          cat.path!.addPoint(closestFood.position);
          cat.path!.resolvePath([closestFood, cat.caterpillar[0]]);
        }

        cat.directionChanged(cat.path!.getDirection() * toAngleConst, 1);
      }
    }
    super.update(t);
  }
}
