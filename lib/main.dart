import 'package:flutter/material.dart';

import './home_menu.dart';
import './countdown_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Countdown',
      theme: ThemeData(
        fontFamily: 'Barlow',
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Final\nCountdown'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TODO: Get data from device
  var countdowns = <Map<String, String>>[
    {"count": '2131', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2131', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2131', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2131', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
    {"count": '2', "type": "test", "name": "diet"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Color(0xffFFFFFF),
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: Color(0xff4C5C68),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_circle_outline,
                size: 32,
                color: Color(0xff4C5C68),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<String>(
              onSelected: (String option) {},
              icon: Icon(
                Icons.more_vert,
                size: 32,
                color: Color(0xFF4C5C68),
              ),
              itemBuilder: (context) {
                return homeMenus.map((menu) => PopupMenuItem(
                      child: Text(menu.label),
                      value: menu.value,
                    )).toList();
              },
            ),
          ),
        ],
      ),
      body: countdowns.length > 0
          ? GridView.count(
              crossAxisCount: 2,
              children: countdowns
                  .map((item) => CountdownItem(
                      count: int.parse(item['count'].toString()),
                      type: item['type'].toString(),
                      name: item['name'].toString()))
                  .toList(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_circle_outline,
                    size: 124,
                    color: Color(0xFFDCDCDD),
                  ),
                  Text(
                    'Add some countdowns...',
                    style: TextStyle(
                      color: Color(0xFFDCDCDD),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
