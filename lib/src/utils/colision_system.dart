import 'dart:math';

import 'package:flutter/material.dart';

import 'package:catterpillardream/src/gameSettings/globals.dart';
import 'package:flame/geometry.dart';
import 'package:flame/components.dart';

const String categoryFood = "food";
const String categoryWall = "wall";
const String categoryBody = "body";

extension SegmentDistance on LineSegment {
  double distanceToPoint(Vector2 point) {
    if (from == to) {
      return from.distanceTo(point);
    }
    if (containsPoint(point)) {
      return 0;
    }
    Line self = toLine();
    Line perpendicular =
        Line(self.b, -1 * self.a, self.a * point.x - self.b * point.y);
    var intersectionsPoints = self.intersections(perpendicular);
    assert(intersectionsPoints.isNotEmpty);
    if (containsPoint(intersectionsPoints[0])) {
      return intersectionsPoints[0].distanceTo(point);
    }
    return min(from.distanceTo(point), to.distanceTo(point));
  }
}

extension CollisionResolver on ShapeComponent {
  static final PolygonPolygonIntersections _ppi = PolygonPolygonIntersections();

  bool mightCollideWithOther(ShapeComponent other) {
    return other.toAbsoluteRect().overlaps(toAbsoluteRect());
  }

  bool circlesColision(CircleComponent first, CircleComponent second) {
    double center2centerDistance = first.center.distanceTo(second.center);
    return first.radius + second.radius <= center2centerDistance;
  }

  bool circlePolygonColision(CircleComponent circle, PolygonComponent polygon) {
    if (polygon.containsPoint(circle.center)) {
      return true;
    }
    var vertices = polygon.globalVertices();
    for (var i = 0; i < vertices.length; ++i) {
      if (polygon
              .getEdge(i, vertices: vertices)
              .distanceToPoint(circle.center) <=
          circle.radius) {
        return true;
      }
    }
    return false;
  }

  bool polygonPolygonColision(PolygonComponent p1, PolygonComponent p2) {
    return _ppi.unorderedIntersect(p1, p2).isNotEmpty;
  }

  bool collidesWithOther(ShapeComponent other) {
    if (mightCollideWithOther(other) == false) {
      return false;
    }
    if (this is CircleComponent && other is CircleComponent) {
      return circlesColision(this as CircleComponent, other);
    }
    if (this is PolygonComponent && other is CircleComponent) {
      return circlePolygonColision(other, this as PolygonComponent);
    }
    if (this is CircleComponent && other is PolygonComponent) {
      return circlePolygonColision(this as CircleComponent, other);
    }
    if (this is PolygonComponent && other is PolygonComponent) {
      return polygonPolygonColision(this as PolygonComponent, other);
    }
    throw ("Shapes not supported");
  }
}

class Pair<T> {
  T first;
  T second;

  Pair(this.first, this.second);
}

class ColisionSystem {
  final Random _random = Random();
  final List<ShapeComponent> _allComponentsCache = [];
  final Map<String, List<ShapeComponent>> _subLists = {};
  List<List<bool>> _theGrid = [];
  double _lastUpdate = double.negativeInfinity;
  Vector2 _lastBasesize = Vector2(0, 0);
  Vector2 _lastScreensize = Vector2(0, 0);

  List<ShapeComponent> getAllComponents({List<String> categories = const []}) {
    if (categories.isEmpty) {
      return _allComponentsCache;
    }
    List<ShapeComponent> shapeComponents = [];
    for (var category in categories) {
      if (_subLists.keys.contains(category)) {
        shapeComponents.addAll(_subLists[category]!);
      } else {
        throw ("$category not initialized in categories: (${_subLists.keys}) ");
      }
    }
    return shapeComponents;
  }

  void addShapeComponent(ShapeComponent component,
      {List<String> categories = const []}) {
    _allComponentsCache.add(component);
    if (categories.isNotEmpty) {
      for (var category in categories) {
        if (_subLists.keys.contains(category)) {
          _subLists[category]!.add(component);
        } else {
          throw ("$category not initialized in categories: (${_subLists.keys}) ");
        }
      }
    }
  }

  void removeShapeComponent(ShapeComponent component) {
    _allComponentsCache.remove(component);
    for (var sublist in _subLists.values) {
      sublist.remove(component);
    }
  }

  void initCathegory(String name) {
    List<ShapeComponent> newList = [];
    _subLists[name] = newList;
  }

  List<ShapeComponent> collisionsOf(ShapeComponent component,
      {List<String> categories = const []}) {
    List<ShapeComponent> collisions = [];
    if (categories.isEmpty) {
      for (var cached in _allComponentsCache) {
        if (cached.collidesWithOther(component)) {
          collisions.add(cached);
        }
      }
    } else {
      for (var category in categories) {
        if (_subLists.keys.contains(category)) {
          for (var cached in _subLists[category]!) {
            if (cached.collidesWithOther(component)) {
              collisions.add(cached);
            }
          }
        } else {
          throw ("$category not in categories: (${_subLists.keys}");
        }
      }
    }
    return collisions;
  }

  List<ShapeComponent> possibleCollisionsOf(ShapeComponent component,
      {List<String> categories = const []}) {
    List<ShapeComponent> collisions = [];
    if (categories.isEmpty) {
      for (var cached in _allComponentsCache) {
        if (cached.mightCollideWithOther(component)) {
          collisions.add(cached);
        }
      }
    } else {
      for (var category in categories) {
        if (_subLists.keys.contains(category)) {
          for (var cached in _subLists[category]!) {
            if (cached.mightCollideWithOther(component)) {
              collisions.add(cached);
            }
          }
        } else {
          throw ("$category not in categories: (${_subLists.keys}");
        }
      }
    }
    return collisions;
  }

  bool checkRectFree(
      List<List<bool>> theGrid, int xStart, int yStart, int width, int height) {
    assert(xStart >= 0 && width > 0 && yStart >= 0 && height > 0);
    assert(xStart < theGrid.length && xStart + width - 1 < theGrid.length);
    assert(
        yStart < theGrid[0].length && yStart + height - 1 < theGrid[0].length);
    for (int x = xStart; x < xStart + width; ++x) {
      for (int y = yStart; y < yStart + height; ++y) {
        if (theGrid[x][y]) {
          return false;
        }
      }
    }
    return true;
  }

  void fillTheGrid(Vector2 screenSize, double gameTime,
      {Vector2? baseSize, bool forceUpdate = false}) {
    bool update = forceUpdate;
    update = update || gameTime > _lastUpdate;
    baseSize ??= SizeProvider.getDoubleVector2Size();
    // get grid size
    int xGridSize = (screenSize.x / baseSize.x).ceil();
    int yGridSize = (screenSize.y / baseSize.y).ceil();
    update = update || xGridSize != _theGrid.length;
    update = update || (_theGrid.isNotEmpty && yGridSize != _theGrid[0].length);
    const double roundingDelta = 0.0001;
    if (update) {
      _lastUpdate = gameTime;
      _lastBasesize = baseSize;
      _lastScreensize = screenSize;
      _theGrid = List.generate(
          xGridSize, (index) => List.filled(yGridSize, false, growable: false),
          growable: false);

      // fill known occupied places
      const List<String> gridVisibleCategories = [
        categoryBody,
        categoryFood,
        categoryFood
      ];
      for (var category in gridVisibleCategories) {
        if (!(_subLists.keys.contains(category))) {
          continue;
        }
        for (var component in _subLists[category]!) {
          var rect = component.toAbsoluteRect();
          int xStart = max((rect.left / baseSize.x + roundingDelta).floor(), 0);
          int width = (rect.width / baseSize.x - roundingDelta).ceil();
          int yStart = max((rect.top / baseSize.y + roundingDelta).floor(), 0);
          int height = (rect.height / baseSize.y - roundingDelta).ceil();
          for (int x = xStart; x < min(xStart + width, xGridSize - 1); ++x) {
            for (int y = yStart; y < min(yStart + height, yGridSize - 1); ++y) {
              _theGrid[x][y] = true;
            }
          }
        }
      }
    }
    /*for (var component in _allComponentsCache) {
        var rect = component.toAbsoluteRect();
        int xStart = max((rect.left / baseSize.x + roundingDelta).floor(), 0);
        int width = (rect.width / baseSize.x - roundingDelta).ceil();
        int yStart = max((rect.top / baseSize.y + roundingDelta).floor(), 0);
        int height = (rect.height / baseSize.y - roundingDelta).ceil();
        for (int x = xStart; x < min(xStart + width, xGridSize - 1); ++x) {
          for (int y = yStart; y < min(yStart + height, yGridSize - 1); ++y) {
            _theGrid[x][y] = true;
          }
        }
      }
    }*/
  }

  Vector2? getRandomFreeSpace(
      Vector2 screenSize, Vector2 requiredSize, double gameTime,
      {Vector2? baseSize}) {
    baseSize ??= SizeProvider.getDoubleVector2Size();
    fillTheGrid(screenSize, gameTime, baseSize: baseSize);
    // get list of possible grid-start positions
    int xObjectSize = (requiredSize.x / baseSize.x).ceil();
    int yObjectSize = (requiredSize.y / baseSize.y).ceil();
    List<Pair<int>> freeCellStarts = [];
    for (int x = 0; x < _theGrid.length - xObjectSize + 1; ++x) {
      for (int y = 0; y < _theGrid[0].length - yObjectSize + 1; ++y) {
        if (_theGrid[x][y] == false) {
          if (checkRectFree(_theGrid, x, y, xObjectSize, yObjectSize)) {
            freeCellStarts.add(Pair<int>(x, y));
          }
        }
      }
    }

    if (freeCellStarts.isNotEmpty) {
      var cellStart = freeCellStarts[_random.nextInt(freeCellStarts.length)];
      double xTolerance = xObjectSize - (requiredSize.x / baseSize.x);
      double yTolerance = yObjectSize - (requiredSize.y / baseSize.y);

      return Vector2(
          cellStart.first * baseSize.x + _random.nextDouble() * xTolerance,
          cellStart.second * baseSize.y + _random.nextDouble() * yTolerance);
    }

    return null;
  }

  void renderGrid(Canvas canvas) {
    fillTheGrid(_lastScreensize, _lastUpdate,
        forceUpdate: true, baseSize: SizeProvider.getVector2Size());
    if (_theGrid.isNotEmpty && _theGrid[0].isNotEmpty) {
      Paint paint = Paint()
        ..color = Colors.grey.shade800
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < _theGrid.length; ++i) {
        for (var j = 0; j < _theGrid[0].length; ++j) {
          if (_theGrid[i][j]) {
            paint.style = PaintingStyle.fill;
          } else {
            paint.style = PaintingStyle.stroke;
          }
          Path path = Path();
          path.addRect(Rect.fromLTRB(i * _lastBasesize.x, j * _lastBasesize.y,
              (i + 1) * _lastBasesize.x, (j + 1) * _lastBasesize.y));
          canvas.drawPath(path, paint);
        }
      }
    }
  }
}
