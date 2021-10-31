import 'dart:ffi';

import 'package:control_pad/control_pad.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/globals.dart';
import 'src/game_core.dart';

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
  Key _key = UniqueKey();

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
  String _message = "";
  ControlSide _controls = ControlSide.right;
  double _size = 150;
  final FocusNode _focusNode = FocusNode();
  int _score = 0;
  late GameCore _game;

  void setMessage(String msg) {
    _message = msg;
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

  void initGame() {
    _game = GameCore(scoreCallback: incrementScore);
  }

  void incrementScore(int score) {
    _score = score;
  }

  // Focus nodes need to be disposed.
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initGame();
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: _focusNode,
        child: Stack(
          children: <Widget>[
            GameWidget(game: _game),
            _createJoyPad(),
            //_createInfoText(),
          ],
        ),
      ),
      //floatingActionButton: _createDPad());
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
