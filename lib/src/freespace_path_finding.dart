import 'dart:math';

import 'package:catterpillardream/src/caterpillar_base.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

import 'globals.dart';
import 'game_core.dart';
import 'food.dart';

class IntersectionInfo {
  int firstIndex;
  int secondIndex;
  Vector2 intersectionPoint;
  IntersectionInfo(this.firstIndex, this.secondIndex, this.intersectionPoint);
}

class CollidableInfo {
  int? segmentIndex;
  Collidable? collidable;
}

class PathComponentSegment extends RectangleComponent {
  Vector2 start;
  Vector2 end;
  PathComponentSegment(
      {required Vector2 size,
      required double angle,
      required Vector2 position,
      required this.start,
      required this.end})
      : super(size: size, angle: angle, position: position) {
    print(size);
    paint.color = Colors.red.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    debugMode = true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), paint);
    super.render(canvas);
  }

  double getDirectionAngle() {
    return CaterpillarPath.getStartEndAngle(start, end);
  }
}

class CaterpillarPath {
  final List<PathComponentSegment> _pathList = [];
  late final double _objectSize;
  late final GameCore _game;
  List<Vector2> points = [];
  CaterpillarPath(this._objectSize, this._game);

  void addPoint(Vector2 point) {
    points.add(point);
    if (points.length >= 2) {
      _pathList.add(getPathCollidable(
          points[points.length - 2], points.last, _objectSize));
      _game.add(_pathList.last);
    }
  }

  void clear() {
    for (var path in _pathList) {
      path.shouldRemove = true;
    }
    points.clear();
    _pathList.clear();
  }

  double getDirection() {
    if (_pathList.isEmpty) {
      return 0;
    }
    return _pathList.first.getDirectionAngle();
  }

// 0, 1, 2, 3 => 3 segments (0,1), (1,2), (2,3)
// index = 2 -> 0, 1, X, 2, 3 => 4 segments (0,1), (1,X), (X, 2), (2,3)
// index = 0 -> X, 0, 1, 2, 3 => 4 segments (X,0), (0,1), (1,2), (2,3)
  void insertPoint(int index, Vector2 point) {
    if (index == points.length) {
      addPoint(point);
    }
    points.insert(index, point);
    if (index > 0) {
      // except for first
      _pathList.removeAt(index - 1);
      var previousPathElement =
          getPathCollidable(points[index - 1], points[index], _objectSize);
      _game.add(previousPathElement);
      _pathList.insert(index - 1, previousPathElement);
    }
    var newPathElement =
        getPathCollidable(points[index], points[index + 1], _objectSize);
    _game.add(newPathElement);
    _pathList.insert(index, newPathElement);
  }

  CollidableInfo _getFirstCollidable() {
    CollidableInfo ret = CollidableInfo();
    List<Collidable> colisions = [];
    int segmentCounter = 0;
    for (var pathSegment in _pathList) {
      for (var gameObject in _game.collidables) {
        if (gameObject is PathComponentSegment) {
          continue;
        }
        if (pathSegment.possiblyOverlapping(gameObject) &&
            colision(pathSegment, gameObject)) {
          colisions.add(gameObject);
        }
      }
      if (colisions.isNotEmpty) {
        //ret.segmentIndex = segmentCounter;
        break;
      }
      ++segmentCounter;
    }
    double minDistance = double.maxFinite;
    for (var col in colisions) {
      double dist = col.center.distanceTo(points.first);
      if (dist < minDistance) {
        minDistance = dist;
        //ret.collidable = col;
      }
    }
    return ret;
  }

  void resolvePath(List<Collidable> collidablesToIgnore) {
    CollidableInfo obstacleInfo = _getFirstCollidable();
    while (obstacleInfo.collidable != null &&
        collidablesToIgnore.contains(obstacleInfo.collidable) == false) {
      var pointsAround = _getPointsAroundComponent(
          obstacleInfo.collidable!,
          _pathList[obstacleInfo.segmentIndex!].start,
          _pathList[obstacleInfo.segmentIndex!].end,
          _objectSize);
      for (int i = 0; i < pointsAround.length; ++i) {
        insertPoint(obstacleInfo.segmentIndex! + i, pointsAround[i]);
      }
      obstacleInfo = _getFirstCollidable();
    }
  }

  IntersectionInfo? _closestIntersectionToStart(
      List<Vector2> points, Vector2 linePointStart, Vector2 linePointEnd) {
    LineSegment line = LineSegment(linePointStart, linePointEnd);
    IntersectionInfo? closestSegment;
    double minDistance = double.maxFinite;
    for (var i = 0; i < points.length; ++i) {
      LineSegment rectLine =
          LineSegment(points[i], points[(i + 1) % points.length]);
      var intersections = rectLine.intersections(line);
      if (intersections.isNotEmpty) {
        double distance = intersections.first.distanceTo(linePointStart);
        if (distance < minDistance) {
          minDistance = distance;
          closestSegment =
              IntersectionInfo(i, (i + 1) % points.length, intersections.first);
        }
      }
    }
    return closestSegment;
  }

  List<Vector2> _getConvexHull(HasHitboxes obstacle) {
    var obstacleRect = obstacle.toRect();
    // TODO: get real shape of HitBox
    List<Vector2> rectPoints = [
      vector2FromOffset(obstacleRect.topLeft),
      vector2FromOffset(obstacleRect.bottomLeft),
      vector2FromOffset(obstacleRect.bottomRight),
      vector2FromOffset(obstacleRect.topRight)
    ];
    return rectPoints;
  }

  Vector2 _getConvexHullCenter(List<Vector2> points) {
    Vector2 ret = Vector2(0, 0);
    for (var point in points) {
      ret += point;
    }
    ret.scale(1.0 / points.length);
    return ret;
  }

  List<Vector2> _getPointsAroundComponent(
      HasHitboxes obstacle, Vector2 start, Vector2 end, double size) {
    var obstacleRect = obstacle.toRect();
    assert(obstacleRect.contains(start.toOffset()) == false &&
        obstacleRect.contains(end.toOffset()) == false);

    List<Vector2> points = [];

    List<Vector2> obstacleHull = _getConvexHull(obstacle);
    IntersectionInfo? intersection =
        _closestIntersectionToStart(obstacleHull, start, end);
    Vector2 center = _getConvexHullCenter(obstacleHull);
    while (intersection != null) {
      Vector2 newPoint = intersection.intersectionPoint +
          (intersection.intersectionPoint - center).normalized().scaled(size);
      points.add(newPoint);
      intersection = _closestIntersectionToStart(obstacleHull, newPoint, end);
    }

    return points;
  }

  static bool colision(HasHitboxes first, HasHitboxes second) {
    for (var hitboxFirst in first.hitboxes) {
      for (var hitboxSecond in second.hitboxes) {
        if (hitboxFirst.intersections(hitboxSecond).isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  static Vector2 vector2FromOffset(Offset offset) {
    return Vector2(offset.dx, offset.dy);
  }

  static double getStartEndAngle(Vector2 start, Vector2 end) {
    Vector2 difference = end - start;
    Vector2 directionReal = Vector2(difference.x, -difference.y);
    double angle = directionReal.angleTo(Vector2(0, 1));
    if (directionReal.x < 0) {
      angle = 2 * pi - angle;
    }
    return angle;
  }

  static PathComponentSegment getPathCollidable(
      Vector2 start, Vector2 end, double objectSize) {
    Vector2 difference = end - start;
    Vector2 shift = Vector2(0, 0);
    difference.scaleOrthogonalInto(
        (-1) * SizeProvider.getSize() / difference.length, shift);
    Vector2 tmp = Vector2(0, 0);
    shift.scaleOrthogonalInto(-1, tmp);
    shift += tmp;

    double ySize = max(.0, (end - start).length - 2.5 * SizeProvider.getSize());
    return PathComponentSegment(
        size: Vector2(objectSize, ySize),
        angle: getStartEndAngle(start, end),
        position: end + shift,
        start: start,
        end: end);
  }
}