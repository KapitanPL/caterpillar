import 'package:control_pad/control_pad.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/gameSettings/globals.dart';
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
  _MyHomePageState createState() => _MyHomePageState();
}

enum ControlSide { left, right }

class _MyHomePageState extends State<MyHomePage> {
  ControlSide _controls = ControlSide.right;
  double _size = 150;
  bool joypadVisible = true;
  late GameWidget _gameWidget;
  late Column _joypad;
  late MainMenuOverllay _mainMenu;
  late InGameMenuOverllay _inGameMenu;
  List<Widget> widgets = [];
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

  void setControls(ControlSide side) {
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
    _game = GameCore(toggleJoyPad, toggleMainMenu);
    _gameWidget = GameWidget(game: _game);
    _joypad = _createJoyPad();
    _mainMenu =
        MainMenuOverllay(key: const Key("mainMenuOverlay"), game: _game);
    _inGameMenu =
        InGameMenuOverllay(key: const Key("inGameMenuOverlay"), game: _game);
    widgets = [
      _gameWidget,
      _joypad,
    ];
  }

  void toggleJoyPad(bool visible) {
    setState(() {
      joypadVisible = visible;
      if (joypadVisible) {
        widgets = [
          _gameWidget,
          _joypad,
        ];
      } else {
        widgets = [
          _gameWidget,
        ];
      }
    });
  }

  void toggleMainMenu({required bool visible, bool inGameMenu = false}) {
    setState(() {
      widgets.remove(inGameMenu ? _inGameMenu : _mainMenu);
      if (visible) {
        widgets.add(inGameMenu ? _inGameMenu : _mainMenu);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _fn.requestFocus();
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _fn,
      child: Scaffold(body: Stack(children: widgets)),
      onKey: (event) {
        print("!!!EVENT!!!");
        _game.processKey(event);
      },
    );
  }

  Column _createJoyPad() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(
          mainAxisAlignment: _controls == ControlSide.right
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
