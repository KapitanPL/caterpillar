import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import 'globals.dart';

typedef EatCallback = void Function(int what);
typedef CrashCallback = void Function();
typedef CaterpiallarCrash = void Function(CaterpillarBase other);
typedef CaterpiallarBodyCrash = void Function(
    CaterpillarBase self, CaterpillarBase other);

class CaterpillarBase extends PositionComponent with Hitbox, Collidable {
  int caterpiallarId;
  double time = 0;
  bool hasGap = false;
  late CaterpiallarCrash caterpiallarCrash;
  CaterpillarBase({required Vector2 position, required this.caterpiallarId})
      : super(position: position, size: SizeProvider.getDoubleVector2Size()) {
    print("something?");
    addHitbox(HitboxCircle());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    print("colision-base");
  }
}

class CaterpiallarHead extends CaterpillarBase {
  /*late EatCallback eatCallback;
  late CrashCallback crashCallback;
  late CaterpiallarCrash caterpiallarCrash;*/
  CaterpiallarHead({required Vector2 position, required int id})
      : super(position: position, caterpiallarId: id) {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    print("colision");
    if (other is CaterpillarBase) {
      caterpiallarCrash(other);
    }
  }
}

class CaterpiallarBody extends CaterpillarBase {
  int type = 0;
  // late CaterpiallarBodyCrash caterpiallarBodyCrash;
  CaterpiallarBody(
      {required Vector2 position, required this.type, required int id})
      : super(position: position, caterpiallarId: id);
  /*@override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is CaterpiallarBody) {
      caterpiallarBodyCrash(this, other);
    }
  }*/
}
