import 'package:hive/hive.dart';

part 'rules.g.dart';

@HiveType(typeId: 1)
class Rules extends HiveObject {
  Rules();
  Rules.from(Rules other) {
    rulesModifiable = true;
    appendInGap = other.appendInGap;
    canColideWithSelf = other.canColideWithSelf;
    semiAutonome = other.semiAutonome;
    shootingEnabled = other.shootingEnabled;
  }

  bool compareRules(Rules other) {
    return appendInGap == other.appendInGap &&
        canColideWithSelf == other.canColideWithSelf &&
        semiAutonome == other.semiAutonome &&
        shootingEnabled == other.shootingEnabled;
  }

  bool rulesModifiable = true;

  @HiveField(0)
  bool appendInGap =
      false; //should the digested food append in the first Gap or at the tail?

  @HiveField(1)
  bool canColideWithSelf =
      false; // should colision with self-body result in death

  @HiveField(2)
  bool semiAutonome =
      false; // in case of no user output, the catterpillar should seek food autonmously

  @HiveField(3)
  bool shootingEnabled =
      false; // should the snake be able to shoot a ball of food to place somewhere
}
