import 'dart:math';

import 'package:catterpillardream/src/pathFinding/freespace_path_finding.dart';
import 'package:catterpillardream/src/views/base_view.dart';
import 'package:catterpillardream/src/views/game_view.dart';
import 'package:catterpillardream/src/views/main_menu_view.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catterpillardream/src/gameComponents/caterpillar.dart';
import 'package:catterpillardream/src/gameComponents/food.dart';
import 'package:catterpillardream/src/utils/primitive_type_wrapper.dart';
import 'gameComponents/walls.dart';

import 'package:catterpillardream/src/gameSettings/globals.dart';
import 'package:catterpillardream/src/gameSettings/ingame_settings.dart';

typedef ToggleVisible = void Function(bool visible);
typedef ToggleMenu = void Function({bool inGameMenu});
typedef EnumChanged<T> = void Function(T value);

extension CollisionResolver on PositionComponent {
  List<Hitbox> getHitboxes() {
    List<Hitbox> finallist = [];
    propagateToChildren((c) {
      if (c is Hitbox) {
        finallist.add(c);
      }
      return true;
    });
    return finallist;
  }

  bool collides(Hitbox hitbox) {
    bool collision = false;
    for (var hb in getHitboxes()) {
      if (hb.intersections(hitbox).isNotEmpty) {
        collision = true;
        if (collision) {
          break;
        }
      }
    }
    return collision;
  }

  bool collidesWithOther(PositionComponent other) {
    bool collision = false;
    for (Hitbox hb in other.getHitboxes()) {
      if (collides(hb)) {
        collision = true;
        break;
      }
    }

    return collision;
  }

  bool collidesWithGame(HasCollisionDetection game) {
    bool collision = false;
    for (var i = 0; i < game.collisionDetection.items.length; ++i) {
      bool possiblyCollides = false;
      for (var hb in getHitboxes()) {
        possiblyCollides =
            game.collisionDetection.items[i].possiblyIntersects(hb);
        if (possiblyCollides) {
          break;
        }
      }
      collision =
          possiblyCollides && collides(game.collisionDetection.items[i]);
      if (collision) {
        break;
      }
    }
    return collision;
  }
}

class GameState {
  // variables
  late GameCore _game;
  GameState({required GameCore game}) {
    _game = game;
  }
  int _value = 0;

  static int pause = 1;
  static int menu = 2;
  // functions
  bool _compare(int val) {
    return _value & val == val;
  }

  void _setValue(bool doSet, int val) {
    if (doSet) {
      _value = _value | val;
    } else {
      _value = _value & ~val;
    }
    _game.onModeChanged();
  }

  bool isPaused() {
    return _compare(pause);
  }

  bool isMenu() {
    return _compare(menu);
  }

  void setPaused(bool paused) {
    _setValue(paused, pause);
  }

  void setMenu(bool setMenu) {
    _setValue(setMenu, menu);
  }
}

class GameCore extends FlameGame with HasCollisionDetection {
  late Vector2 screenSize;
  final Map<BaseViewType, BaseView> _views = {};
  late BaseViewType _activeView;
  late final GameState gameState;
  final Random _random = Random();
  ToggleVisible? toggleJoypadCallback;
  ToggleVisible? toggleMainMenuCallback;

  final List<PositionComponent> positionComponentsCache = [];
  final List<FoodBase> food = [];

  EnumChanged<JoypadPosition>? joypadPositionChanged;

  GameCore() {
    gameState = GameState(game: this);
    gameState.setMenu(true);
    RulesProvider.initBasicRules();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _views[BaseViewType.Game] = GameView(this);
    _views[BaseViewType.MainMenu] = MainMenuView(this);
    _activeView = BaseViewType.MainMenu;
    onViewActivated();
  }

  void onViewActivated() {
    _views[_activeView]?.activate();
    toggleJoypadCallback?.call(_activeView == BaseViewType.Game);
    toggleMainMenuCallback?.call(_activeView == BaseViewType.Game);
  }

  BaseView? getActiveView() {
    return _views[_activeView];
  }

  void onModeChanged() {
    toggleMainMenuCallback?.call(_activeView == BaseViewType.Game);
  }

  void startNewGame() {
    _views[_activeView]?.deactivate();
    gameState.setMenu(false);
    _activeView = BaseViewType.Game;
    onViewActivated();
  }

  void endGameAndBackToMain() {
    _views[_activeView]?.deactivate();
    _activeView = BaseViewType.MainMenu;
    pauseGame(false);
    onViewActivated();
  }

  void joypadChanged(double degrees, double distance) {
    _views[_activeView]?.joypadChanged(degrees, distance);
  }

  Caterpillar createNewCaterpillar(
      PrimitiveTypeWrapper<int> lastAssociatedId, Vector2 initPosition) {
    lastAssociatedId.val++;
    return Caterpillar(lastAssociatedId.val, this, initPosition);
  }

  void addWall(
      {required List<Vector2> points,
      double thickness = 10,
      bool close = false}) {
    if (points.length > 1) {
      for (var i = 0; i < points.length - 1; ++i) {
        addWallBetweenPoints(start: points[i], end: points[i + 1]);
      }
      if (close && points.length > 2) {
        addWallBetweenPoints(start: points.last, end: points.first);
      }
    }
  }

  void addWallBetweenPoints(
      {required Vector2 start, required Vector2 end, double thickness = 10}) {
    Vector2 difference = end - start;
    Vector2 directionReal = Vector2(-difference.x, difference.y);
    double angle = directionReal.angleTo(Vector2(0, 1));
    if (directionReal.x < 0) {
      angle = 2 * pi - angle;
    }
    WallBase wall = WallBase(
        size: Vector2(thickness, difference.length + thickness),
        position: Vector2(start.x - thickness / 2, start.y - thickness / 2),
        angle: angle);
    add(wall);
  }

  void addFood({required Set<int> colors, Vector2? position}) {
    FoodBase newFood = FoodBase(
        position: position ??
            Vector2(_random.nextDouble() * screenSize.x,
                _random.nextDouble() * screenSize.y),
        type: colors.elementAt(_random.nextInt(colors.length)),
        eaten: () => addFood(colors: colors));

    while (newFood.collidesWithGame(this) && position == null) {
      newFood = FoodBase(
          position: Vector2(_random.nextDouble() * screenSize.x,
              _random.nextDouble() * screenSize.y),
          type: colors.elementAt(_random.nextInt(colors.length - 1)),
          eaten: () => addFood(colors: colors));
    }
    add(newFood);
  }

  @override
  void update(double dt) {
    if (dt > 0 && dt < 1 /*&& !gameState.isPaused()*/) {
      _views[_activeView]?.update(dt);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    _views[_activeView]?.render(canvas);
    super.render(canvas);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    screenSize = canvasSize;
    super.onGameResize(screenSize);
  }

  void processKey(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.escape &&
          _activeView == BaseViewType.Game) {
        pauseGame(!gameState.isPaused());
        gameState.setMenu(!gameState.isMenu());
      }
    }
  }

  void mouseMoved(PointerEvent event) {
    if (_activeView == BaseViewType.Game &&
        GameSettings.controls == Controls.tapPoint) {
      double degrees = CaterpillarPath.getStartEndAngle(
          _views[_activeView]!.getHeadCenterPosition(),
          Vector2(event.position.dx, event.position.dy));
      degrees = 360 * degrees / 2 / pi;
      _views[_activeView]?.joypadChanged(degrees, 1);
    }
  }

  void pauseGame(bool pause) {
    gameState.setPaused(pause);
    if (pause) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  @override
  Future<void>? add(Component component) {
    if (component is PositionComponent) {
      positionComponentsCache.add(component);
    }
    if (component is FoodBase) {
      food.add(component);
    }
    return super.add(component);
  }

  @override
  Future<void> addAll(Iterable<Component> components) {
    for (Component component in components) {
      if (component is PositionComponent) {
        positionComponentsCache.add(component);
      }
      if (component is FoodBase) {
        food.add(component);
      }
    }
    return super.addAll(components);
  }

  @override
  void remove(Component component) {
    if (component is PositionComponent) {
      positionComponentsCache.remove(component);
      if (component is! PathComponentSegment && component is! FoodBase) {
        print("removing really something");
      }
    }
    if (component is FoodBase) {
      food.remove(component);
    }
    super.remove(component);
  }
}
