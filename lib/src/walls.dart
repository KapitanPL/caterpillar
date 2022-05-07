import 'package:catterpillardream/src/globals.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

class WallBase extends RectangleComponent with CollisionCallbacks {
  bool isDestructible = false;
  List<Vector2> _points = [];
  Vector2? _center;
  WallBase({
    required Vector2 size,
    this.isDestructible = false,
    Paint? paint,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          paint: paint,
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    add(RectangleHitbox());
  }

  void setPointsAround(List<List<Vector2>> points) {
    _points.clear();
    for (var pts in points) {
      _points.addAll(pts);
    }
  }

  void setCenterPoint(Vector2 center) {
    _center = absoluteToLocal(center);
  }

  void drawCross(Canvas canvas, Vector2 point, double size, Paint paint) {
    canvas.drawLine(Offset(point.x - size, point.y - size),
        Offset(point.x + size, point.y + size), paint);
    canvas.drawLine(Offset(point.x - size, point.y + size),
        Offset(point.x + size, point.y - size), paint);
  }

  @override
  void render(Canvas canvas) {
    if (_points.isNotEmpty) {
      Paint paint = Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..color = Colors.lightGreen;

      for (var point in _points) {
        canvas.drawCircle(
            absoluteToLocal(point).toOffset(), SizeProvider.getSize(), paint);
      }
    }

    if (_center != null) {
      drawCross(canvas, _center!, 10, paint);
    }

    super.render(canvas);
  }
}
