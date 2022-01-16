import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'caterpillar_base.dart';
import 'color_maps.dart';
import 'freespace_path_finding.dart';
import 'globals.dart';
import 'trajectory.dart';

typedef IterateCallback = void Function(int index, dynamic arg);

class Caterpillar {
  final FlameGame _game;
  late final int _caterpiallarId;
  List<CaterpillarBase> caterpillar = [];
  Vector2 _velocity = Vector2(1, -1);
  Vector2 _acceleration = Vector2(0, 0);
  final double _accelerationModifier = 4;
  final Vector2 _zeroAngle = Vector2(0, 1);
  final Trajectory trajectory = Trajectory();
  CaterpillarPath? path;

  bool drawTrajectory = false;
  Caterpillar(this._caterpiallarId, this._game, Vector2 initPosition) {
    var head = CaterpillarHead(id: _caterpiallarId, position: initPosition);
    caterpillar.add(head);
    _game.add(head);
    head.caterpillarCrash = genericCrash;
    head.caterpillarEat = eat;
    trajectory.addPoint(head.time, head.position);
  }

  void setVelocity(Vector2 velocity) {
    _velocity = velocity;
  }

  void iterateCaterpillar(IterateCallback function, dynamic arg) {
    for (var i = 0; i < caterpillar.length; ++i) {
      function(i, arg);
    }
  }

  int id() {
    return _caterpiallarId;
  }

  void genericCrash(CaterpillarBase other) {}

  void appendNewPiece(int what) {
    var newPiece = CaterpillarBody(
        position: caterpillar.last.position, type: what, id: _caterpiallarId);
    newPiece.time = caterpillar.last.time;
    caterpillar.add(newPiece);
    _game.add(newPiece);
  }

  void eat(int what) {
    CaterpillarHead head = caterpillar[0] as CaterpillarHead;
    head.foodToProcess.add(what);
  }

  void initBodyRandomCount(int initLength, Set<int> initColors) {
    bool isValid = false;
    var rand = Random();
    List<bool> isColorUsed = List<bool>.filled(initColors.length, false);
    Vector2 headPosition = caterpillar[0].position;
    List<CaterpillarBase> body = [];

    int iteration = 0;
    int maxIt = 10;
    while (isValid == false && iteration < maxIt) {
      for (var i = 0; i < initLength; ++i) {
        int next = rand.nextInt(initColors.length);
        body.add(CaterpillarBody(
            position: headPosition,
            type: initColors.elementAt(next),
            id: _caterpiallarId));
        isColorUsed[next] = true;
      }

      isValid = true;
      for (var element in isColorUsed) {
        isValid &= element;
        if (!isValid) {
          isColorUsed = List<bool>.filled(initColors.length, false);
          body.clear();
        }
      } // for
      iteration++;
    } // while

    if (isValid = false) {
      for (var i = 0; i < initLength; ++i) {
        body.add(CaterpillarBody(
            position: headPosition,
            type: initColors.elementAt(i % colorMap.length),
            id: _caterpiallarId));
      }
    }

    (body[0] as CaterpillarBody).canColideWithHead = false;
    caterpillar.addAll(body);
    _game.addAll(body);
  }

  void initBodyPaternCount(int count, List<int> pattern) {}

  void initBodyList(List<int> pattern) {
    CaterpillarHead head = caterpillar[0] as CaterpillarHead;
    head.foodToProcess.addAll(pattern);
  }

  void directionChanged(double direction, double distance) {
    if (distance > 0) {
      double angle = 2 * pi * direction / 360;
      _acceleration.x = _accelerationModifier * distance * sin(angle);
      _acceleration.y = _accelerationModifier * distance * cos(angle);
    } else {
      _acceleration = Vector2(0, 0);
    }
  }

  void update(double dt) {
    _velocity += _acceleration * dt;
    _velocity = _velocity.normalized();
    double direction =
        _zeroAngle.angleTo(_velocity) * (_velocity.x.isNegative ? -1 : 1);
    CaterpillarHead head = caterpillar[0] as CaterpillarHead;
    head.time += _velocity.length > 0 ? dt : 0;
    if (trajectory.isTimeValid(head.time)) {
      head.position = trajectory.getPoint(head.time);
    } else {
      double distance = SpeedProvider.headSpeed() * dt * _velocity.length;
      head.position +=
          Vector2(distance * sin(direction), distance * (-1) * cos(direction));
      trajectory.addPoint(head.time, head.position);
    }
    if (head.foodToProcess.isNotEmpty && head.food.isValid() == false) {
      head.setFood(head.foodToProcess.first);
      head.foodToProcess.removeAt(0);
    }
    moveFoodFrom(0);

    iterateCaterpillar(moveElement, dt);

    trajectory.dispatchPointsUpTo(caterpillar.last.time);
  }

  void moveElement(int index, dynamic deltaTime) {
    assert(deltaTime is double);
    double dt = deltaTime;
    double timeDiff = 2 * SizeProvider.getSize() / SpeedProvider.headSpeed();
    // head is already moved in the main move function
    if (index > 0) {
      var bodyPart = caterpillar[index] as CaterpillarBody;
      var previousElement = caterpillar[index - 1];
      if ((previousElement.time - bodyPart.time) > timeDiff) {
        bodyPart.time +=
            bodyPart.isFast ? dt * SpeedProvider.gapSpeedFactor() : dt;

        if (bodyPart.isFast && index + 1 < caterpillar.length
            //&& (caterpillar[index].time - caterpillar[index + 1].time >1.5 * timeDiff)
            ) {
          (caterpillar[index + 1] as CaterpillarBody).isFast = true;
        }

        if (bodyPart.time > previousElement.time - timeDiff) {
          bodyPart.time = previousElement.time - timeDiff;
          bool hadGap = bodyPart.hasGap;
          bodyPart.hasGap = false;
          bodyPart.isFast = false;
          if (hadGap) {
            checkForChainReactionOnTap(index);
          }
        }
        bodyPart.position = trajectory.getPoint(bodyPart.time);
      }
      bodyPart.food.incrementTime(dt);
      double foodTime = 2 * SizeProvider.getSize() / SpeedProvider.foodSpeed();
      if (bodyPart.food.isValid() && bodyPart.food.time > foodTime) {
        moveFoodFrom(index);
      }
    }
  }

  void moveFoodFrom(int index) {
    int nextIndex = index + 1;
    var thisPiece = caterpillar[index];
    int food = thisPiece.food.food;
    if (thisPiece.food.isValid() == false) {
      return;
    }
    if (nextIndex < caterpillar.length) {
      var nextPiece = (caterpillar[nextIndex] as CaterpillarBody);

      if (nextPiece.hasGap && Rules.APPEND_IN_GAP) {
        CaterpillarBody newPiece = CaterpillarBody(
            position: thisPiece.position, type: food, id: _caterpiallarId);
        newPiece.time = thisPiece.time;
        caterpillar.insert(index, newPiece);
        _game.add(newPiece);
        thisPiece.food.reset();
        return;
      }

      if (nextPiece.food.isValid() == false) {
        nextPiece.setFood(food);
        thisPiece.food.reset();
        checkForChainReactionWithFood(nextIndex, food);
        return;
      }
    } else {
      appendNewPiece(food);
      thisPiece.food.reset();
    }
  }

  void checkForChainReactionWithFood(int index, int foodType) {
    if ((caterpillar[index] as CaterpillarBody).type != foodType) {
      return;
    }
    int minIndex = index;
    int maxIndex = index;
    while (minIndex > 1 &&
        (caterpillar[minIndex] as CaterpillarBody).hasGap == false &&
        foodType == (caterpillar[minIndex - 1] as CaterpillarBody).type) {
      --minIndex;
    }
    while (maxIndex < caterpillar.length - 1 &&
        (caterpillar[maxIndex + 1] as CaterpillarBody).hasGap == false &&
        foodType == (caterpillar[maxIndex + 1] as CaterpillarBody).type) {
      ++maxIndex;
    }
    if (maxIndex - minIndex + 1 >= 3) {
      doChainReaction(minIndex, maxIndex);
    }
  }

  void checkForChainReactionOnTap(int index) {
    int minIndex = index;
    int maxIndex = index;
    while (minIndex > 1 &&
        (caterpillar[minIndex] as CaterpillarBody).hasGap == false &&
        (caterpillar[minIndex] as CaterpillarBody).type ==
            (caterpillar[minIndex - 1] as CaterpillarBody).type) {
      --minIndex;
    }
    while (maxIndex < caterpillar.length - 1 &&
        (caterpillar[maxIndex + 1] as CaterpillarBody).hasGap == false &&
        (caterpillar[maxIndex] as CaterpillarBody).type ==
            (caterpillar[maxIndex + 1] as CaterpillarBody).type) {
      ++maxIndex;
    }
    if (maxIndex - minIndex + 1 >= 3) {
      doChainReaction(minIndex, maxIndex);
    }
  }

  void doChainReaction(int minIndex, int maxIndex) {
    for (int i = minIndex; i <= maxIndex; ++i) {
      caterpillar[i].shouldRemove = true;
    }
    if (maxIndex + 1 < caterpillar.length) {
      (caterpillar[maxIndex + 1] as CaterpillarBody).hasGap = true;
      (caterpillar[maxIndex + 1] as CaterpillarBody).isFast = true;
    }
    caterpillar.removeRange(minIndex, maxIndex + 1);
  }

  void render(Canvas canvas) {
    if (drawTrajectory) {
      var trajectoryPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2;
      late Offset previousPoint;
      bool first = true;
      for (Vector2 point in trajectory.getPoints()) {
        if (first) {
          previousPoint = Offset(point.x, point.y);
          first = false;
          continue;
        }
        Offset nextPoint = Offset(point.x, point.y);
        canvas.drawLine(previousPoint, nextPoint, trajectoryPaint);
        previousPoint = nextPoint;
      }
    }
  }
}
