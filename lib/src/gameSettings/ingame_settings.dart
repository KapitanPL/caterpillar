enum Controls {
  tapPoint,
  joypad,
}

enum JoypadPosition {
  right,
  left,
}

class GameSettings {
  static Controls controls = Controls.tapPoint;
  static JoypadPosition joypadPosition = JoypadPosition.right;
}
