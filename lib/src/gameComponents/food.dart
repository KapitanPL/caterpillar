import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

import 'caterpillar_base.dart';
import 'package:catterpillardream/src/gameSettings/color_maps.dart';
import 'package:catterpillardream/src/gameSettings/globals.dart';

typedef FoodEatenCallback = void Function();

class FoodBase extends CircleComponent {
  double _time = 0;
  int type = 0;
  FoodEatenCallback eaten;
  static var rand = Random();
  bool _wasEaten = false;
  FoodBase({required Vector2 position, required this.type, required this.eaten})
      : super(position: position, radius: SizeProvider.getSize()) {
    anchor = Anchor.center;

    _time = rand.nextDouble();
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = colorMap[type]!;

    double sizeFactor = /*sin(3 * _time) * sin(3 * _time) / 2 + 0.5*/ 1;
    List<Offset> pathPoints = [
      (const Offset(1, 0) * SizeProvider.getSize() * sizeFactor +
          SizeProvider.getVector2Size().toOffset()),
      (const Offset(0, 1) * SizeProvider.getSize() * sizeFactor +
          SizeProvider.getVector2Size().toOffset()),
      (const Offset(-1, 0) * SizeProvider.getSize() * sizeFactor +
          SizeProvider.getVector2Size().toOffset()),
      (const Offset(0, -1) * SizeProvider.getSize() * sizeFactor +
          SizeProvider.getVector2Size().toOffset())
    ];

    Path path = Path();
    path.addPolygon(pathPoints, true);
    canvas.drawPath(path, paint);
    //super.render(canvas);
  }

  /*@override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CaterpillarHead) {
      _wasEaten = true;
    }
  }*/

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void onRemove() {
    if (_wasEaten) {
      eaten();
    }
    super.onRemove();
  }
}
