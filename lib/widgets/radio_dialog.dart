import 'package:flutter/material.dart';

class RadioDialog {
  static Future<String?> show(BuildContext context, String? initialValue) async {
    String? _selected = initialValue ?? 'option1';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose an Option'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('sell item in kampus mart'),
                  value: 'option1',
                  groupValue: _selected,
                  onChanged: (value) => setState(() => _selected = value),
                ),
                RadioListTile<String>(
                  title: Text('get something from kampusmart'),
                  value: 'option2',
                  groupValue: _selected,
                  onChanged: (value) => setState(() => _selected = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
