import 'package:flutter/material.dart';

class StringDialog extends StatefulWidget {
  @override
  State createState() => _StringDialogState();

  final String titleString;
  final String? Function(String)? valueValidator;

  StringDialog({super.key, required this.titleString, this.valueValidator});
}

class _StringDialogState extends State<StringDialog> {
  String value = "";
  bool saveEnabled = true;
  @override
  void initState() {
    super.initState();
  }

  String? get _errorText {
    if (widget.valueValidator == null) {
      return null;
    }
    String? error = widget.valueValidator!.call(value);
    setState(() {
      saveEnabled = error == null;
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.titleString),
        content: TextField(
          autofocus: true,
          onChanged: (val) {
            setState(() {
              value = val;
            });
          },
          decoration: InputDecoration(errorText: _errorText),
        ),
        actions: [
          ElevatedButton(
            onPressed:
                (saveEnabled ? () => Navigator.pop(context, value) : null),
            style: ElevatedButton.styleFrom(
              primary:
                  saveEnabled ? Colors.green : Colors.grey, // Background color
            ),
            child: const Text("Save"),
          ),
          ElevatedButton(
              onPressed: (() => Navigator.pop(context, "")),
              child: const Text("Cancel"))
        ]);
  }
}
