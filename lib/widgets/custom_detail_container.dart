// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class CustomDetailContainer extends StatefulWidget {
  final Color fontColor;
  final double fontSize;
  final String initialText;
  final double containerWidth;
  final double containerHeight;
  final IconData iconData;

  const CustomDetailContainer({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.initialText,
    required this.containerHeight,
    required this.containerWidth,
    required this.iconData,
  });

  @override
  State<CustomDetailContainer> createState() => _EditableDetailContainerState();
}

class _EditableDetailContainerState extends State<CustomDetailContainer> {
  late bool isEditing;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;

      // Optionally: Save when toggled off
      if (!isEditing) {
        final savedText = _controller.text;
        // TODO: save to DB/local storage if needed
        // ignore: avoid_print
        print("Saved: $savedText");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Container(
        constraints: BoxConstraints(
          minHeight: widget.containerHeight,
          minWidth: widget.containerWidth,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.borderGrey.withOpacity(0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: widget.fontColor,
                          fontSize: widget.fontSize,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                        onSubmitted: (_) => toggleEdit(), // optional
                      )
                    : Text(
                        _controller.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.fontColor,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w900
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.check : widget.iconData,
                  color: widget.fontColor,
                  size: widget.fontSize + 2,
                ),
                onPressed: toggleEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
