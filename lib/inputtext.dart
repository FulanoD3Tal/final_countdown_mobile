import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  const Input({
    Key? key,
    required this.label,
    this.required = false,
    this.textArea = true,
  }) : super(key: key);

  final String label;
  final bool required;
  final bool textArea;

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 4),
          child: Text(
            '${widget.label} ${widget.required ? '*' : ''}',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff4C5C68),
            ),
          ),
        ),
        TextField(
          maxLines: widget.textArea ? null : 1,
          decoration: InputDecoration(
            fillColor: Color(0xFFDCDCDD),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
              gapPadding: 0,
            ),
            focusColor: Color(0xffFFFFFF),
          ),
        ),
      ],
    );
  }
}
