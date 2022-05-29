import 'dart:io' show Platform;
import 'package:catterpillardream/src/gameSettings/globals.dart';
import 'package:catterpillardream/src/gameSettings/rules.dart';
import 'package:catterpillardream/src/game_core.dart';
import 'package:catterpillardream/src/menu_overlays/widgets/string_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catterpillardream/src/gameSettings/ingame_settings.dart';

import 'package:catterpillardream/src/menu_overlays/widgets/button_selectors.dart';

typedef ButtonCallback = void Function();

enum MenuContext { Root, Options, Controls, Rules, NewGameMenu }

class MenuOverllay extends StatefulWidget {
  final GameCore game;
  MenuOverllay({required Key key, required this.game}) : super(key: key);

  @override
  MenuOverllayState createState() => MenuOverllayState();
}

class MenuOverllayState extends State<MenuOverllay> {
  MenuContext menuContext = MenuContext.Root;
  bool ruleHintsVisible = false;
  String? rulesKey;
  Rules? rules;
  MenuOverllayState();

  ElevatedButton button(String text, ButtonCallback callback) {
    return ElevatedButton(
      child: Text(text),
      onPressed: () {
        callback();
      },
    );
  }

  Column menuGroup(List<Widget> widgets) {
    List<Widget> children = [];
    for (var w in widgets) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 10));
      }
      children.add(w);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IntrinsicWidth(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children),
        ),
      ])
    ]);
  }

  Column controls(BuildContext context) {
    List<Widget> buttons = [];
    // controls
    bool isDesktop = kIsWeb
        ? (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)
        : (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    String tapPointName = isDesktop ? "Mouse" : "Touch";
    buttons.addAll([
      const Text("Controls: ",
          style: TextStyle(
            color: Colors.amber,
          )),
      RadioButtonList<Controls>(
        key: const Key("RadioControls"),
        captions: ["Joypad", tapPointName],
        values: const <Controls>{Controls.joypad, Controls.tapPoint},
        initValue: Controls.joypad,
        onButtonChanged: (Controls value) => setState(() {
          GameSettings.controls = value;
        }),
      )
    ]);
    if (GameSettings.controls == Controls.joypad) {
      buttons.addAll([
        const Text("Joypad position: ",
            style: TextStyle(
              color: Colors.amber,
            )),
        RadioButtonList<JoypadPosition>(
          key: const Key("RadioControlsPosition"),
          captions: const ["Left", "Right"],
          values: const <JoypadPosition>{
            JoypadPosition.left,
            JoypadPosition.right
          },
          initValue: JoypadPosition.right,
          onButtonChanged: (JoypadPosition value) {
            widget.game.joypadPositionChanged?.call(value);
          },
        )
      ]);
    }
    // back
    buttons.add(button(
        "Back to Main",
        () => {
              setState(() {
                menuContext = MenuContext.Root;
              })
            }));
    return menuGroup(buttons);
  }

  Column mainOptions(BuildContext context) {
    List<Widget> buttons = [
      button(
          "Rules",
          () => {
                setState(() {
                  menuContext = MenuContext.Rules;
                })
              }),
      button(
          "Back to Main",
          () => {
                setState(() {
                  menuContext = MenuContext.Root;
                })
              }),
    ];
    return menuGroup(buttons);
  }

  ListTile createCheckBoxItem(
      {required String title,
      required bool value,
      required void Function(bool?)? onChanged}) {
    Color color = Colors.amber;
    Color getColor(Set<MaterialState> states) {
      return color;
    }

    return ListTile(
      title: Text(title,
          style: TextStyle(
            color: color,
          )),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        checkColor: Colors.black,
      ),
    );
  }

  Column newGameMenu(BuildContext context) {
    return Column();
  }

  Column rulesSection(BuildContext context) {
    List<Widget> buttons = [];
    rulesKey ??= widget.game.getActiveView()!.currentRules;
    List<PopupMenuItem<String>> menuItems = [];
    for (String key in RulesProvider.keys()) {
      menuItems.add(PopupMenuItem<String>(
          value: key,
          child: Text(key,
              style: const TextStyle(
                color: Colors.white,
              ))));
    }
    Rules storedRules = RulesProvider.getRules(rulesKey!)!;
    rules ??= Rules.from(storedRules);

    buttons.add(Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: PopupMenuButton<String>(
          color: Colors.green,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.arrow_downward_outlined,
              color: Colors.white,
            ),
            Text(
              rulesKey!,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            )
          ]),
          onSelected: (String key) {
            setState(() {
              rules = null;
              rulesKey = key;
            });
          },
          itemBuilder: (BuildContext context) => menuItems,
        )));
    if (!rules!.compareRules(storedRules)) {
      buttons.add(const Text("MODIFIED",
          style: TextStyle(
            color: Colors.red,
          )));
    }
    buttons.add(createCheckBoxItem(
        title: "Shooting enabled",
        value: rules!.shootingEnabled,
        onChanged: (bool? value) {
          setState(() {
            rules!.shootingEnabled = value!;
          });
        }));
    buttons.add(createCheckBoxItem(
        title: "Append in gap",
        value: rules!.appendInGap,
        onChanged: (bool? value) {
          setState(() {
            rules!.appendInGap = value!;
          });
        }));
    buttons.add(createCheckBoxItem(
        title: "Can colide with self",
        value: rules!.canColideWithSelf,
        onChanged: (bool? value) {
          setState(() {
            rules!.canColideWithSelf = value!;
          });
        }));
    buttons.add(createCheckBoxItem(
      title: "Semi-autonome",
      value: rules!.semiAutonome,
      onChanged: (bool? value) {
        setState(() {
          rules!.semiAutonome = value!;
        });
      },
    ));
    if (storedRules.rulesModifiable && !rules!.compareRules(storedRules)) {
      buttons.add(button("Save", () {
        setState(() {
          RulesProvider.modifyRules(rulesKey!, rules!);
          rules = null;
        });
      }));
    }
    if (!rules!.compareRules(storedRules)) {
      buttons.add(button(
          "Save as",
          () => setState(() {
                Future<String?> newName = showDialog(
                  context: context,
                  builder: (context) => StringDialog(
                    key: const Key("SaveRulesDialog"),
                    titleString: "Save rules as",
                    valueValidator: (String value) {
                      if (RulesProvider.isKeyAvailable(value)) {
                        return null;
                      }
                      return "Name already used.";
                    },
                  ),
                );
                newName.then((value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      RulesProvider.addRules(value, rules!);
                      rulesKey = value;
                      rules = null;
                    });
                  }
                });
              })));
    }
    buttons.add(button(
        "Back to Options",
        () => {
              setState(() {
                rules = null;
                menuContext = MenuContext.Root;
              })
            }));
    return menuGroup(buttons);
  }

  Column mainMenu(BuildContext context) {
    return Column();
  }

  @override
  Widget build(BuildContext context) {
    switch (menuContext) {
      case MenuContext.Root:
        {
          return mainMenu(context);
        }
      case MenuContext.Options:
        {
          return mainOptions(context);
        }
      case MenuContext.Controls:
        {
          return controls(context);
        }
      case MenuContext.Rules:
        {
          return rulesSection(context);
        }
      case MenuContext.NewGameMenu:
        {
          return newGameMenu(context);
        }
    }
  }
}
