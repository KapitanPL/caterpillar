import 'dart:ffi';

import 'package:control_pad/control_pad.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/globals.dart';
import 'src/game_core.dart';
import 'src/main_menu_overlay.dart';

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
  MyHomePage({required Key key}) : super(key: key);

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
  List<Widget> widgets = [];
  late GameCore _game;

  _MyHomePageState() : super() {
    init();
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
    _game = GameCore();
    _gameWidget = GameWidget(game: _game);
    _joypad = _createJoyPad();
    widgets = [
      _gameWidget,
      _joypad,
      //MainMenuOverllay(key: const Key("overlay"), game: _game)
    ];
  }

  void toggleJoyPad() {
    setState(() {
      if (joypadVisible) {
        widgets = [
          _gameWidget,
          _joypad,
          ElevatedButton(child: const Text("try"), onPressed: toggleJoyPad),
        ];
      } else {
        widgets = [
          _gameWidget,
          ElevatedButton(child: const Text("try"), onPressed: toggleJoyPad),
        ];
      }
      joypadVisible = !joypadVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: widgets),
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