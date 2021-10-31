import 'package:flame/components.dart';

class SizeProvider {
  static double _staticSize = 5;
  static void setSize(double size) {
    _staticSize = size;
  }

  static double getSize() {
    return _staticSize;
  }

  static Vector2 getVector2Size() {
    return Vector2(_staticSize, _staticSize);
  }

  static Vector2 getDoubleVector2Size() {
    return Vector2(2 * _staticSize, 2 * _staticSize);
  }
}

class SpeedProvider {
  static int _gapSpeedFactor = 15;
  static int _foodSpeedFactor = 15;
  static int _headSpeedFactor = 50;

  static int headSpeed() {
    return _headSpeedFactor;
  }

  static int foodSpeed() {
    return _foodSpeedFactor;
  }

  static int gapSpeed() {
    return _gapSpeedFactor;
  }
}
