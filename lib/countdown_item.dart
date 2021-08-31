import 'package:flutter/material.dart';

class CountdownItem extends StatelessWidget {
  final int count;
  final String type;
  final String name;
  const CountdownItem(
      {Key? key, required this.count, required this.type, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFDCDCDD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              blurRadius: 25,
              offset: Offset(0, 4),
              color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C5C68),
            ),
          ),
          Text(
            type,
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF4C5C68),
            ),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4C5C68),
            ),
          ),
        ],
      ),
    );
  }
}
