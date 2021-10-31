import 'dart:math';
import 'dart:ui';
import 'package:catterpillardream/src/caterpillar_base.dart';
import 'package:catterpillardream/src/globals.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'caterpillar_base.dart';
import 'globals.dart';
import 'trajectory.dart';

typedef IterateCallback = void Function(int index, dynamic arg);

class Caterpillar {
  late final int _caterpiallarId;
  List<CaterpillarBase> caterpillar = [];
  Vector2 _velocity = Vector2(1, -1);
  Vector2 _acceleration = Vector2(0, 0);
  double _accelerationModifier = 2;
  final Vector2 _zeroAngle = Vector2(0, 1);
  final Trajectory _trajectory = Trajectory();
  bool drawTrajectory = false;
  Map<int, Color> colorMap = {
    1: Colors.red,
    2: Colors.blue,
    3: Colors.yellow,
    4: Colors.green
  };
  Caterpillar(this._caterpiallarId) {
    caterpillar.add(
        CaterpiallarHead(id: _caterpiallarId, position: Vector2(100, 100)));
    _trajectory.addPoint(caterpillar[0].time, caterpillar[0].position);
  }

  void iterateCaterpillar(IterateCallback function, dynamic arg) {
    for (var i = 0; i < caterpillar.length; ++i) {
      function(i, arg);
    }
  }

  int id() {
    return _caterpiallarId;
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
        body.add(CaterpiallarBody(
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
        body.add(CaterpiallarBody(
            position: headPosition,
            type: initColors.elementAt(i),
            id: _caterpiallarId));
      }
    }

    caterpillar.addAll(body);
  }

  void initBodyPaternCount(int count, List<int> pattern) {}

  void initBodyList(List<int> pattern) {}

  void directionChanged(double direction, double distance) {
    if (distance > 0) {
      double angle = 2 * pi * direction / 360;
      _acceleration.x = _accelerationModifier * distance * sin(angle);
      _acceleration.y = _accelerationModifier * distance * cos(angle);
    }
  }

  void update(double dt) {
    _velocity += _acceleration * dt;
    _velocity = _velocity.normalized();
    double direction =
        _zeroAngle.angleTo(_velocity) * (_velocity.x.isNegative ? -1 : 1);
    caterpillar[0].time += dt;
    double distance = SpeedProvider.headSpeed() * dt;
    caterpillar[0].position +=
        Vector2(distance * sin(direction), distance * (-1) * cos(direction));
    _trajectory.addPoint(caterpillar[0].time, caterpillar[0].position);

    iterateCaterpillar(moveElement, dt);

    _trajectory.dispatchPointsUpTo(caterpillar.last.time);
  }

  void moveElement(int index, dynamic deltaTime) {
    assert(deltaTime is double);
    double dt = deltaTime;
    double timeDiff = 2 * SizeProvider.getSize() / SpeedProvider.headSpeed();
    // head is already moved in the main move function
    if (index > 0) {
      if ((caterpillar[index - 1].time - caterpillar[index].time) > timeDiff) {
        caterpillar[index].time += dt;
        caterpillar[index].position =
            _trajectory.getPoint(caterpillar[index].time);
      }
    }
  }

  void paint(Canvas canvas) {
    var paint = Paint();
    Paint bckg = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var item in caterpillar) {
      if (item is CaterpiallarBody) {
        paint.color = colorMap[item.type]!;
        bckg.color = Colors.black;
      } else {
        paint.color = Colors.white;
        bckg.color = Colors.red;
      }
      item.renderHitboxes(canvas);
      canvas.drawCircle(Offset(item.position.x, item.position.y),
          SizeProvider.getSize(), paint);
      canvas.drawCircle(Offset(item.position.x, item.position.y),
          SizeProvider.getSize() - 2, bckg);
    }
    if (drawTrajectory) {
      var trajectoryPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2;
      late Offset previousPoint;
      bool first = true;
      for (Vector2 point in _trajectory.getPoints()) {
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
