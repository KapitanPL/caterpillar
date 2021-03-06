import 'package:flame/components.dart';
import 'package:catterpillardream/src/gameSettings/rules.dart';
import 'package:catterpillardream/src/gameSettings/ingame_settings.dart';
import 'package:hive/hive.dart';

const String SETTINGS_NAME = 'settings';

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
  static double _gapSpeedFactor = 3;
  static double _foodSpeedFactor = 3;
  static double _headSpeedFactor = 100;
  static double _freeBodySpeed = 500;

  static double headSpeed() {
    return _headSpeedFactor;
  }

  static double foodSpeed() {
    return _foodSpeedFactor * _headSpeedFactor;
  }

  static double gapSpeedFactor() {
    return _gapSpeedFactor;
  }

  static double freeBodySpeed() {
    return _freeBodySpeed;
  }
}

class RulesProvider {
  static Future<void> initBasicRules() async {
    Hive.registerAdapter(RulesAdapter());
    Rules gameRules = Rules();
    gameRules.rulesModifiable = false;
    addRules("Game Rules", gameRules);

    Rules menuRules = Rules();
    menuRules.canColideWithSelf = true;
    menuRules.rulesModifiable = false;
    addRules("Menu Rules", menuRules);

    var storedSettings = await Hive.openBox(SETTINGS_NAME);
    for (var key in storedSettings.keys) {
      if (key is String && key.startsWith("Rules:")) {
        String nakedKey = key.substring(6);
        addRules(nakedKey, storedSettings.get(key), save: false);
      }
    }
  }

  static final Map<String, Rules> _rules = {};

  static Rules? getRules(String key) {
    return _rules[key];
  }

  static bool isKeyAvailable(String key) {
    return !_rules.keys.contains(key);
  }

  static Future<bool> addRules(String key, Rules rules,
      {bool save = true}) async {
    if (isKeyAvailable(key)) {
      _rules[key] = rules;

      if (save && rules.rulesModifiable) {
        var storedSettings = await Hive.openBox(SETTINGS_NAME);
        storedSettings.put("Rules:$key", rules);
      }

      return true;
    }
    return false;
  }

  static void modifyRules(String key, Rules rules) async {
    if (rules.rulesModifiable) {
      _rules[key] = rules;
      var storedSettings = await Hive.openBox(SETTINGS_NAME);
      storedSettings.put("Rules:$key", rules);
    }
  }

  static void deleteRules(String key) {
    _rules.remove(key);
  }

  static Iterable<String> keys() {
    return _rules.keys;
  }
}

class MiscelaneousGlobals {
  static int FOOD_GRADIENT_COUNT = 10;
}
