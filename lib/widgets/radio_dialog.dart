import 'package:flutter/material.dart';
import 'package:kampusmart2/theme/app_theme.dart';

class RadioDialog {
  static Future<String?> show(BuildContext context, String? initialValue) async {
    String? _selected = initialValue ?? 'option1';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.deepBlue.withOpacity(0.97),
          title: Center(child: Text('Choose an Option', style: TextStyle(color: AppTheme.paleWhite),)),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('sell item in kampus mart', style: TextStyle(color: AppTheme.paleWhite),),
                  value: 'option1',
                  groupValue: _selected,
                  onChanged: (value) => setState(() => _selected = value),
                ),
                RadioListTile<String>(
                  title: Text('get something from kampusmart', style: TextStyle(color: AppTheme.paleWhite),),
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
              child: Text('Cancel', style: TextStyle(color: AppTheme.paleWhite),),
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
