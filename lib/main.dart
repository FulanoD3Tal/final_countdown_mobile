import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:final_coutdown/db_helpers/sqlite_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import './home_menu.dart';
import './countdown_item.dart';
import './form.dart';
import './models/countdown.dart';
import 'detail.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Countdown',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
  final db = CountdownProvider.instance;
  late List<Countdown> countdowns;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshCountdowns();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  Future refreshCountdowns() async {
    setState(() {
      isLoading = true;
    });
    this.countdowns = await db.getAll();
    setState(() {
      isLoading = false;
    });
  }

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
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FormCountdown(),
                ));
                refreshCountdowns();
              },
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
              onSelected: (String option) async {
                switch (option) {
                  case 'private-policy':
                    await launchUrl(Uri.parse(policyUrl));
                    break;
                  default:
                }
              },
              icon: Icon(
                Icons.more_vert,
                size: 32,
                color: Color(0xFF4C5C68),
              ),
              itemBuilder: (context) {
                return homeMenus
                    .map((menu) => PopupMenuItem(
                          child: Text(menu.label),
                          value: menu.value,
                        ))
                    .toList();
              },
            ),
          ),
        ],
      ),
      body: !isLoading && countdowns.length > 0
          ? GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(26),
              crossAxisSpacing: 40,
              mainAxisSpacing: 15,
              children: countdowns
                  .map(
                    (item) => CountdownItem(
                      countdown: item,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => DetailCountdown(
                                    countdownId: item.id,
                                  )),
                        );
                        refreshCountdowns();
                      },
                    ),
                  )
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
                    AppLocalizations.of(context)!.addMoreItems,
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
