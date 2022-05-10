enum Controls {
  tapPoint,
  joypad,
}

enum JoipadPosition {
  right,
  left,
}

class GameSettings {
  static Controls controls = Controls.joypad;
  static JoipadPosition joypadPosition = JoipadPosition.right;
}
