import 'dart:io';

import 'package:control_pad/control_pad.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'src/gameSettings/globals.dart';
import 'src/gameSettings/ingame_settings.dart';
import 'src/game_core.dart';
import 'src/menu_overlays/main_menu_overlay.dart';
import 'src/menu_overlays/ingame_manu_overlay.dart';

//zen mode - score only
//map mode - candy-crush
//duel mode - local/online multiplayer
//
//highest score wins
//last men standing
//first to clean up
//
//init length
//speed

void main() {
  var path = Directory.current.path;
  Hive.init(path);
  SizeProvider.setSize(20);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Key _key = UniqueKey();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(key: _key),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key}) : super(key: key);

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  JoypadPosition _controls = JoypadPosition.right;
  double _size = 150;
  bool joypadVisible = true;
  bool inGameMenu = false;
  late GameWidget _gameWidget;
  late MainMenuOverllay _mainMenu;
  late InGameMenuOverllay _inGameMenu;
  late GameCore _game;
  final FocusNode _fn = FocusNode();

  _MyHomePageState() : super() {
    init();
  }

  @override
  void dispose() {
    _fn.dispose();
    super.dispose();
  }

  void setControls(JoypadPosition side) {
    setState(() {
      _controls = side;
    });
  }

  void setControlsSize(double size) {
    setState(() {
      _size = size;
    });
  }

  void joypadChanged(double degrees, double distance) {
    // _message = "Degrees ${degrees.floor()}, distance: ${distance.floor()}";
    _game.joypadChanged(degrees, distance);
  }

  void init() {
    _game = GameCore()
      ..toggleJoypadCallback = toggleJoyPad
      ..toggleMainMenuCallback = toggleMainMenu
      ..joypadPositionChanged = setControls;
    _gameWidget = GameWidget(game: _game);
    _mainMenu =
        MainMenuOverllay(key: const Key("mainMenuOverlay"), game: _game);
    _inGameMenu =
        InGameMenuOverllay(key: const Key("inGameMenuOverlay"), game: _game);
    joypadVisible = GameSettings.controls == Controls.joypad;
  }

  void toggleJoyPad(bool visible) {
    setState(() {
      joypadVisible = visible;
    });
  }

  void toggleMainMenu(bool gameMenu) {
    setState(() {
      inGameMenu = gameMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    _fn.requestFocus();
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _fn,
      child: Listener(
        child: Scaffold(body: Stack(children: getWidgets())),
        onPointerMove: (event) => _game.mouseMoved(event),
        onPointerHover: (event) => _game.mouseMoved(event),
      ),
      onKey: (event) {
        _game.processKey(event);
      },
    );
  }

  List<Widget> getWidgets() {
    List<Widget> widgets = [_gameWidget];
    if (GameSettings.controls == Controls.joypad && joypadVisible) {
      widgets.add(_createJoyPad());
    }
    if (_game.gameState.isMenu()) {
      if (inGameMenu) {
        widgets.add(_inGameMenu);
      } else {
        widgets.add(_mainMenu);
      }
    }
    return widgets;
  }

  Column _createJoyPad() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(
          mainAxisAlignment: _controls == JoypadPosition.right
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            JoystickView(
              size: _size,
              onDirectionChanged: joypadChanged,
            ),
          ])
    ]);
  }
}
