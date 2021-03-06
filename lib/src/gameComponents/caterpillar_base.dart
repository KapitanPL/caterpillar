import 'dart:ui';
import 'dart:math';

import 'package:catterpillardream/src/gameComponents/food.dart';
import 'package:catterpillardream/src/gameComponents/walls.dart';
import 'package:catterpillardream/src/gameComponents/caterpillar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

import 'package:catterpillardream/src/gameSettings/color_maps.dart';
import 'package:catterpillardream/src/gameSettings/globals.dart';

typedef EatCallback = void Function(FoodBase what);
typedef CrashCallback = void Function();
typedef CaterpillarCrash = void Function(CaterpillarBase other);
typedef CaterpillarBodyCrash = void Function(
    CaterpillarBase self, CaterpillarBase other);

class FoodInCaterpillar {
  int food = -1;
  double time = 0;

  bool isValid() {
    return food != -1;
  }

  void setFood(int what) {
    food = what;
    time = .0;
  }

  void reset() {
    food = -1;
    time = .0;
  }

  bool incrementTime(double dt) {
    if (!isValid()) return false;
    time += dt;
    return true;
  }
}

class CaterpillarBase extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  Caterpillar? caterpiallar;
  double time = 0;
  FoodInCaterpillar food = FoodInCaterpillar();
  List<CaterpillarBase> colisions = [];
  CaterpillarCrash? caterpillarCrash;
  final Offset _center = SizeProvider.getDoubleVector2Size().toOffset() / 2;
  CaterpillarBase({required Vector2 position, required this.caterpiallar})
      : super(position: position, size: SizeProvider.getDoubleVector2Size()) {
    add(CircleHitbox());
  }

  void setFood(int type) {
    food.food = type;
    food.time = 0;
  }
}

class CaterpillarHead extends CaterpillarBase {
  /*late EatCallback eatCallback;
  late CrashCallback crashCallback;
  late caterpillarCrash caterpillarCrash;*/
  bool wallCollided = false;
  EatCallback? caterpillarEat;
  FoodBase? foodInMouth;
  List<int> foodToProcess = [];

  CaterpillarHead({required Vector2 position, required Caterpillar? cat})
      : super(position: position, caterpiallar: cat);

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CaterpillarBase && caterpillarCrash != null) {
      caterpillarCrash!(other);
    } else if (other is FoodBase && caterpillarEat != null) {
      caterpillarEat!(other);
      other.removeFromParent();
    } else if (other is WallBase) {
      wallCollided = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    wallCollided = false;
    super.onCollisionEnd(other);
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Colors.white;
    Paint bckg = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = wallCollided ? Colors.green : Colors.red;
    canvas.drawCircle(_center, SizeProvider.getSize(), paint);
    canvas.drawCircle(_center, SizeProvider.getSize() - 2, bckg);
    if (foodInMouth != null) {
      canvas.drawCircle(_center, SizeProvider.getSize() / 2, paint);
      Paint foodPaint = Paint()..color = colorMap[foodInMouth!.type]!;
      canvas.drawCircle(_center, SizeProvider.getSize() / 2 - 2, foodPaint);
    }
    super.render(canvas);
  }
}

class CaterpillarBody extends CaterpillarBase {
  int type = 0;
  bool isColided = false;
  bool canColideWithHead = true;
  bool hasGap = false;
  bool isFast = false;
  // late CaterpillarBodyCrash CaterpillarBodyCrash;
  CaterpillarBody(
      {required Vector2 position, required this.type, required Caterpillar cat})
      : super(position: position, caterpiallar: cat);

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..color = colorMap[type]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = SizeProvider.getSize() / 10;
    canvas.drawCircle(_center, SizeProvider.getSize(), paint);
    canvas.drawCircle(_center, SizeProvider.getSize() * 2 / 3, paint);
    canvas.drawCircle(_center, SizeProvider.getSize() / 3, paint);

    /*if (hasGap) {
      canvas.drawRect(
          (position - SizeProvider.getVector2Size())
              .toPositionedRect(SizeProvider.getVector2Size() * 2),
          paint);
    }*/

    if (food.isValid()) {
      Paint foodPaint = Paint()..color = colorMap[food.food]!.withOpacity(
          //i.toDouble() / MiscelaneousGlobals.FOOD_GRADIENT_COUNT);
          0.2);
      var sizeNormalizationCoeff =
          MiscelaneousGlobals.FOOD_GRADIENT_COUNT / 2 / SizeProvider.getSize();
      for (var i = 0; i < MiscelaneousGlobals.FOOD_GRADIENT_COUNT; ++i) {
        canvas.drawCircle(
            _center,
            SizeProvider.getSize() +
                (i - MiscelaneousGlobals.FOOD_GRADIENT_COUNT / 2) /
                    sizeNormalizationCoeff,
            foodPaint);
      }
    }
    //debugMode = true;
    super.render(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CaterpillarHead && canColideWithHead) {
      isColided = true;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    isColided = false;
  }
}

class FreeBodyPart extends CaterpillarBase {
  double direction;
  int type;
  FreeBodyPart(
      {required Vector2 position, required this.direction, required this.type})
      : super(caterpiallar: null, position: position);

  @override
  void update(double dt) {
    position += Vector2(sin(direction), -cos(direction)) *
        SpeedProvider.freeBodySpeed() *
        dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = colorMap[type]!;
    canvas.drawCircle(_center, SizeProvider.getSize(), paint);

    //debugMode = true;
    super.render(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CaterpillarBase) {
      CaterpillarBase theOther = other;
      theOther.colisions.add(this);
      theOther.caterpiallar?.checkFreeBodyInsert(this);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is CaterpillarBase) {
      CaterpillarBase theOther = other;
      theOther.colisions.remove(this);
    }
  }
}
