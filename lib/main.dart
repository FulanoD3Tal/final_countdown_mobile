import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'
    hide DebugGeography, ConsentStatus, ConsentRequestParameters, ConsentDebugSettings;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import 'package:final_coutdown/db_helpers/sqlite_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import './home_menu.dart';
import './countdown_item.dart';
import './form.dart';
import './models/countdown.dart';
import 'detail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    const apiKey = String.fromEnvironment('GOOGLE_STORE_PUBLIC_API', defaultValue: '');
    configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Final Countdown',
        navigatorObservers: [observer],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          fontFamily: 'Barlow',
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(
          title: 'Final\nCountdown',
          analytics: analytics,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.analytics}) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = CountdownProvider.instance;

  // final _ump = UserMessagingPlatform.instance;
  // TrackingAuthorizationStatus? _consentInformation;
  // bool _tagAsUnderAgeOfConsent = false;
  // bool _debugSettings = false;
  // String? _testDeviceId;
  // DebugGeography _debugGeography = DebugGeography.disabled;

  late List<Countdown> countdowns;
  bool isLoading = false;
  bool freeAds = false;

  @override
  void initState() {
    super.initState();
    updateConsent();
    refreshCountdowns();
    getPurchaseStatus();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  void updateConsent() async {
    // Make sure to continue with the latest consent info.
    var _ump = UserMessagingPlatform.instance;
    var info = await _ump.requestConsentInfoUpdate(
        // new ConsentRequestParameters(
        //   debugSettings: new ConsentDebugSettings(
        //     testDeviceIds: ['F4BD52507B2A84800D794A72477524A6'],
        //     geography: DebugGeography.EEA,
        //   ),
        // ),
        );

    // Show the consent form if consent is required.
    if (info.consentStatus == ConsentStatus.required) {
      // `showConsentForm` returns the latest consent info, after the consent from has been closed.
      info = await UserMessagingPlatform.instance.showConsentForm();
    }
  }

  void getPurchaseStatus() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    setState(() {
      freeAds = customerInfo.entitlements.all["Free ads"]!.isActive;
    });
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
          if (freeAds == false) ...[
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.removeAds,
                onPressed: () async {
                  try {
                    Offerings offerings = await Purchases.getOfferings();
                    if (offerings.current != null) {
                      List<Package> packages = offerings.current!.availablePackages;
                      CustomerInfo customerInfo = await Purchases.purchasePackage(packages[0]);
                      final snackBar = SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.thanksForSupport,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        freeAds = customerInfo.entitlements.all["Free ads"]!.isActive;
                      });
                    }
                  } on PlatformException catch (e) {
                    var errorCode = PurchasesErrorHelper.getErrorCode(e);
                    if (errorCode != PurchasesErrorCode.purchaseCancelledError) {}
                  }
                },
                icon: Icon(
                  Icons.ads_click,
                  size: 32,
                  color: Color(0xff4C5C68),
                ),
              ),
            )
          ],
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              tooltip: AppLocalizations.of(context)!.addMoreItems,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FormCountdown(),
                    settings: new RouteSettings(
                      name: '/form',
                    ),
                  ),
                );
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
            padding: EdgeInsets.only(right: 10.0),
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
                              analytics: widget.analytics,
                            ),
                            settings: new RouteSettings(
                              name: '/detail',
                            ),
                          ),
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
