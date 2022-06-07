import 'dart:math';

import 'package:catterpillardream/src/gameComponents/walls.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

import 'package:catterpillardream/src/gameSettings/globals.dart';
import 'package:catterpillardream/src/game_core.dart';

class IntersectionInfo {
  int leftIndex;
  int rightIndex;
  Vector2 intersectionPoint;
  IntersectionInfo(this.leftIndex, this.rightIndex, this.intersectionPoint);
}

class PositionComponentInfo {
  int? segmentIndex;
  PositionComponent? positionComponent;
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
    paint.color = Colors.red.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
  }

  @override
  void render(Canvas canvas) {
    if (shouldRemove) {
      return;
    }
    // canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), paint);
    //super.render(canvas);
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
      _pathList.add(getPathPositionComponent(
          points[points.length - 2], points.last, _objectSize));
      _game.add(_pathList.last);
    }
  }

  void clear() {
    for (var path in _pathList) {
      path.removeFromParent();
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
      _pathList[index - 1].removeFromParent();
      _pathList.removeAt(index - 1);
      var previousPathElement = getPathPositionComponent(
          points[index - 1], points[index], _objectSize);
      _game.add(previousPathElement);
      _pathList.insert(index - 1, previousPathElement);
    }
    var newPathElement =
        getPathPositionComponent(points[index], points[index + 1], _objectSize);
    _game.add(newPathElement);
    _pathList.insert(index, newPathElement);
  }

  PositionComponentInfo _getFirstCollidingPositionComponentForPathPoints(
      List<PositionComponent> positionComponentsToIgnore,
      List<Vector2> pathPoints,
      double objectSize) {
    PositionComponentInfo ret = PositionComponentInfo();
    List<PositionComponent> colisions = [];
    int segmentCounter = 0;
    for (var i = 0; i < pathPoints.length - 1; ++i) {
      var pathSegment = getPathPositionComponent(
          pathPoints[i], pathPoints[i + 1], objectSize);
      for (var gameComponent in _game.positionComponentsCache) {
        if (gameComponent is PathComponentSegment) {
          continue;
        }
        if (positionComponentsToIgnore.contains(gameComponent)) {
          continue;
        }
        if (pathSegment.collidesWithOther(gameComponent)) {
          colisions.add(gameComponent);
        }
      }
      if (colisions.isNotEmpty) {
        ret.segmentIndex = segmentCounter;
        break;
      }
      ++segmentCounter;
    }
    double minDistance = double.maxFinite;
    for (var col in colisions) {
      double dist = col.center.distanceTo(pathPoints.first);
      if (dist < minDistance) {
        minDistance = dist;
        ret.positionComponent = col;
      }
    }
    return ret;
  }

  PositionComponentInfo _getFirstPositionComponent(
      List<PositionComponent> positionComponentsToIgnore) {
    PositionComponentInfo ret = PositionComponentInfo();
    List<PositionComponent> colisions = [];
    int segmentCounter = 0;
    for (var pathSegment in _pathList) {
      for (var gameObject in _game.positionComponentsCache) {
        if (gameObject is PathComponentSegment) {
          continue;
        }
        if (positionComponentsToIgnore.contains(gameObject)) {
          continue;
        }
        if (pathSegment.collidesWithOther(gameObject)) {
          colisions.add(gameObject);
        }
      }
      if (colisions.isNotEmpty) {
        ret.segmentIndex = segmentCounter;
        break;
      }
      ++segmentCounter;
    }
    double minDistance = double.maxFinite;
    for (var col in colisions) {
      double dist = col.center.distanceTo(points.first);
      if (dist < minDistance) {
        minDistance = dist;
        ret.positionComponent = col;
      }
    }
    return ret;
  }

  void resolvePath(List<PositionComponent> PositionComponentsToIgnore) {
    PositionComponentInfo obstacleInfo =
        _getFirstPositionComponent(PositionComponentsToIgnore);
    if (obstacleInfo.positionComponent != null) {
      var pointsAround = _getPointsAroundComponent(
          obstacleInfo.positionComponent!,
          _pathList[obstacleInfo.segmentIndex!].start,
          _pathList[obstacleInfo.segmentIndex!].end,
          _objectSize);
      double minDistance = double.infinity;
      // while (pointsAround.isNotEmpty) {}
      for (int i = 0; i < pointsAround[0].length; ++i) {
        insertPoint(obstacleInfo.segmentIndex! + i + 1, pointsAround[0][i]);
      }
    }
  }

// TODO work with rect with width of objectsize rather then line
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

  List<Vector2> _getConvexHull(PositionComponent obstacle) {
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

  Vector2 _getPathPoint(Vector2 center, Vector2 edgePoint, double size) {
    return edgePoint + (edgePoint - center).normalized().scaled(size);
  }

  void _walkAroundComponent(List<Vector2> obstacleHull, Vector2 hullCenter,
      List<Vector2> points, Vector2 end, double size, bool left) {
    while (true) {
      IntersectionInfo? intersection =
          _closestIntersectionToStart(obstacleHull, points.last, end);
      if (intersection != null) {
        points.add(_getPathPoint(
            hullCenter,
            obstacleHull[
                left ? intersection.leftIndex : intersection.rightIndex],
            size));
      } else {
        break;
      }
    }
  }

  List<List<Vector2>> _getPointsAroundComponent(
      PositionComponent obstacle, Vector2 start, Vector2 end, double size) {
    /*var obstacleRect = obstacle.toRect();
    assert(obstacleRect.contains(start.toOffset()) == false &&
        obstacleRect.contains(end.toOffset()) == false);*/

    List<List<Vector2>> points = [[], []];

    List<Vector2> obstacleHull = _getConvexHull(obstacle);
    IntersectionInfo? intersection =
        _closestIntersectionToStart(obstacleHull, start, end);
    Vector2 center = _getConvexHullCenter(obstacleHull);

    if (intersection != null) {
      points[0].add(
          _getPathPoint(center, obstacleHull[intersection.leftIndex], size));
      points[1].add(
          _getPathPoint(center, obstacleHull[intersection.rightIndex], size));
      _walkAroundComponent(obstacleHull, center, points[0], end, size, true);
      _walkAroundComponent(obstacleHull, center, points[1], end, size, false);
    }

    if (obstacle is WallBase) {
      obstacle.setPointsAround(points);
      obstacle.setCenterPoint(center);
    }

    return points;
  }

  double computePathLength(Vector2 start, Vector2 end, List<Vector2> points) {
    double ret = 0;
    if (points.isEmpty) {
      ret = (start - end).length;
    } else {
      ret += (start - points.first).length;
      ret += (end - points.last).length;
      if (points.length > 1) {
        for (var i = 0; i < points.length - 1; ++i) {
          ret += (points[i] - points[i + 1]).length;
        }
      }
    }
    return ret;
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

  static PathComponentSegment getPathPositionComponent(
      Vector2 start, Vector2 end, double objectSize) {
    Vector2 difference = end - start;
    Vector2 shift = Vector2(0, 0);
    difference.scaleOrthogonalInto(
        (-1) * SizeProvider.getSize() / difference.length, shift);
    /*Vector2 tmp = Vector2(0, 0);
    shift.scaleOrthogonalInto(-1, tmp);
    shift += tmp;*/

    double ySize =
        max(.0, (end - start).length /*- 2.5 * SizeProvider.getSize()*/);
    return PathComponentSegment(
        size: Vector2(objectSize, ySize),
        angle: getStartEndAngle(start, end),
        position: end + shift,
        start: start,
        end: end);
  }
}
