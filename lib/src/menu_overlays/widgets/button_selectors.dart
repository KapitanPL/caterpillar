import 'package:flutter/material.dart';

typedef ButtonChangedCallback<T> = void Function(T value);

class RadioButtonList<T> extends StatefulWidget {
  final List<String> captions;
  final Set<T> values;
  final T initValue;
  final ButtonChangedCallback<T>? onButtonChanged;
  const RadioButtonList(
      {required Key key,
      required this.captions,
      required this.values,
      required this.initValue,
      this.onButtonChanged})
      : super(key: key);

  @override
  _RadioButtonListState createState() => _RadioButtonListState<T>();
}

class _RadioButtonListState<T> extends State<RadioButtonList<T>> {
  T? _currentValue;

  @override
  Widget build(BuildContext context) {
    _currentValue ??= widget.initValue;
    List<ElevatedButton> buttons = [];
    for (int i = 0; i < widget.captions.length; ++i) {
      buttons.add(ElevatedButton(
        onPressed: () {
          buttonPressed(widget.values.elementAt(i));
        },
        child: Text(widget.captions[i]),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                widget.values.elementAt(i) == _currentValue
                    ? Colors.red
                    : Colors.green)),
      ));
    }
    return Row(
      children: buttons,
    );
  }

  void buttonPressed(T value) {
    widget.onButtonChanged?.call(value);
    setState(() {
      _currentValue = value;
    });
  }
}
