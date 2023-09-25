import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:final_coutdown/form.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'db_helpers/sqlite_helper.dart';
import 'models/countdown.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

class DetailCountdown extends StatefulWidget {
  final countdownId;

  final FirebaseAnalytics analytics;
  const DetailCountdown({
    Key? key,
    required this.countdownId,
    required this.analytics,
  }) : super(key: key);

  @override
  _DetailCountdownState createState() => _DetailCountdownState();
}

class _DetailCountdownState extends State<DetailCountdown> {
  final db = CountdownProvider.instance;
  late Countdown? countdown;
  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = false;
  bool isLoading = false;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  static const adUnitId = String.fromEnvironment("ADMOB_DETAIL_UNIT_ID",defaultValue: "");

  void loadAd() {
    if (Platform.isAndroid) {
      InterstitialAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            // Called when an ad is successfully received.
            onAdLoaded: (ad) {
              debugPrint('$ad loaded.');
              setState(() {
                _isAdLoaded = true;
              });
              // Keep a reference to the ad so you can show it later.
              _interstitialAd = ad;
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              debugPrint(error.message);
            },
          ));
    }
  }

  @override
  void initState() {
    super.initState();

    loadAd();
    refreshCountdown();
  }

  Future refreshCountdown() async {
    setState(() {
      isLoading = true;
    });
    this.countdown = await db.find(widget.countdownId);
    setState(() {
      isLoading = false;
    });
  }

  takeScreenShotAndShare() async {
    final directory = (await getApplicationDocumentsDirectory()).path;

    screenshotController
        .captureAndSave(directory, fileName: 'screenshot.png', pixelRatio: 2.0)
        .then((value) {
      Share.shareFiles(['$directory/screenshot.png'],
          text: AppLocalizations.of(context)!.sharePlaceholder(
              'https://play.google.com/store/apps/details?id=com.fulanod3tal.final_coutdown'));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        if (_isAdLoaded) {
          _interstitialAd.show();
        }
        return Future.value(true);
      },
      child: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          backgroundColor: Color(0xffFFFFFF),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            backgroundColor: Color(0xffFFFFFF),
            leading: IconButton(
                onPressed: () {
                  if (_isAdLoaded) {
                    _interstitialAd.show();
                  }
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 32,
                  color: Color(0xff4C5C68),
                )),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: IconButton(
                  onPressed: () async {
                    takeScreenShotAndShare();
                    await widget.analytics.logEvent(
                        name: 'share', parameters: {'content_type': 'image'});
                  },
                  icon: Icon(
                    Icons.share,
                    size: 32,
                    color: Color(0xff4C5C68),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FormCountdown(
                        id: countdown?.id,
                      ),
                    ));
                    refreshCountdown();
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 32,
                    color: Color(0xff4C5C68),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: IconButton(
                  onPressed: () {
                    _showDialog(context, countdown?.id);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: 32,
                    color: Color(0xff4C5C68),
                  ),
                ),
              ),
            ],
          ),
          body: isLoading
              ? null
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: size.height,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.15),
                              height: size.height - (size.height * 0.15),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 19, vertical: 60),
                              width: size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFDCDCDD),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 25,
                                      offset: Offset(0, 4),
                                      color: Colors.black.withOpacity(0.1)),
                                ],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (countdown!.goal -
                                                      countdown!.count) ==
                                                  0
                                              ? AppLocalizations.of(context)!
                                                  .countdownFinished(
                                                      countdown!.name,
                                                      countdown!.type)
                                              : AppLocalizations.of(context)!
                                                  .countdownOnGoing(
                                                      countdown!.name,
                                                      countdown!.goal,
                                                      countdown!.type),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 32,
                                            color: Color(0xff4C5C68),
                                          ),
                                          maxLines: 2,
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 30),
                                      child: (countdown!.goal -
                                                  countdown!.count) ==
                                              0
                                          ? null
                                          : ElevatedButton(
                                              onPressed: () async {
                                                countdown?.count++;
                                                await db.update(countdown);
                                                refreshCountdown();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                  Color(0xff1985A1),
                                                ),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .removeOne
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 55),
                                          child: count(),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ])
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, int? countdownId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.delete),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await db.delete(countdownId);
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          );
        });
  }

  Text count() {
    return Text(
      (countdown!.goal - countdown!.count) == 0
          ? countdown!.goal.toString()
          : (countdown!.goal - countdown!.count).toString(),
      style: TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w700,
          color: (countdown!.goal - countdown!.count) == 0
              ? Color(0xff1985A1)
              : Color(0xff4C5C68),
          shadows: [
            Shadow(
              blurRadius: 25,
              offset: Offset(0, 4),
              color: Colors.black.withOpacity(0.2),
            ),
          ]),
    );
  }
}
