import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String label;
  final bool required;
  final bool textArea;
  final Function(String? value) onSaved;
  final TextInputType? keyboardType;
  
  const Input({
    Key? key,
    required this.label,
    required this.onSaved,
    this.required = false,
    this.textArea = true,
    this.keyboardType,
  }) : super(key: key);


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
        TextFormField(
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,
          validator: (value) {
            if (widget.required && (value == null || value.isEmpty)) {
              return 'Field required';
            }
            return null;
          },
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
