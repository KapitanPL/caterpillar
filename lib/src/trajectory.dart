import 'package:flame/components.dart';

class OutOfBoundsException implements Exception {
  @override
  String toString() {
    return 'Parameter outside of maximum bounds, no interpolation possible.';
  }
}

class Trajectory {
  Trajectory();
  final List<double> _times = [];
  final List<Vector2> _points = [];

  void addPoint(double t, Vector2 p) {
    assert(_times.length == _points.length);
    assert(_times.isEmpty || t >= _times.last);
    _points.add(p.clone());
    _times.add(t);
  }

  void addPointDeltaT(double dt, Vector2 p) {
    assert(_times.length == _points.length);
    _points.add(p);
    if (_times.isNotEmpty) {
      _times.add(_times.last + dt);
    } else {
      _times.add(0);
    }
  }

  void dispatchPointsUpTo(double t) {
    assert(_times.length == _points.length);
    int startIndex = 0;
    int endIndex = 0;
    while (_times[endIndex] < t) {
      ++endIndex;
    }
    if (endIndex > startIndex) {
      _times.removeRange(startIndex, endIndex - 1);
      _points.removeRange(startIndex, endIndex - 1);
    }
    assert(_times.length == _points.length);
  }

  Vector2 getPoint(double t) {
    assert(_points.length > 1);
    assert(_times.length == _points.length);
    if (t < _times.first || t > _times.last) {
      throw OutOfBoundsException();
    }
    int biggerIndex = _times.indexWhere((element) => element > t);
    assert(biggerIndex > 0);
    double t1 = _times[biggerIndex - 1];
    double t2 = _times[biggerIndex];
    assert(t2 > t && t1 <= t);
    double coefA = (t - t1) / (t2 - t1);
    double coefB = (t2 - t) / (t2 - t1);
    return _points[biggerIndex - 1] * coefA + _points[biggerIndex] * coefB;
  }

  double getLastTime() {
    if (_times.isEmpty) {
      return 0;
    }
    return _times.last;
  }

  List<Vector2> getPoints() {
    return _points;
  }
}
