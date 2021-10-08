import 'package:final_coutdown/models/countdown.dart';
import 'package:flutter/material.dart';

class CountdownItem extends StatelessWidget {
  final Countdown countdown;
  final Function onTap;
  const CountdownItem({
    Key? key,
    required this.countdown,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int count = countdown.goal - countdown.count;
    bool finished = count == 0;
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: finished ? Color(0xff1985A1) : Color(0xFFDCDCDD),
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
              finished ? countdown.goal.toString() : (count).toString(),
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: finished ? Color(0xffFFFFFF) : Color(0xFF4C5C68),
              ),
            ),
            Text(
              countdown.type.toString(),
              style: TextStyle(
                fontSize: 24,
                color: finished ? Color(0xffFFFFFF) : Color(0xFF4C5C68),
              ),
            ),
            Text(
              countdown.name.toString(),
              style: TextStyle(
                fontSize: 12,
                color: finished ? Color(0xffFFFFFF) : Color(0xFF4C5C68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
