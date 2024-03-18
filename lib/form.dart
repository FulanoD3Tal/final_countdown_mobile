import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'db_helpers/sqlite_helper.dart';
import './models/countdown.dart';

class FormCountdown extends StatefulWidget {
  final int? id;

  const FormCountdown({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<FormCountdown> {
  final db = CountdownProvider.instance;
  final _formKey = GlobalKey<FormState>();
  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = false;
  bool isLoading = false;

  static const adUnitId = String.fromEnvironment("ADMOB_FORM_UNIT_ID", defaultValue: "");

  void loadAd() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    EntitlementInfo? entitlementInfo = customerInfo.entitlements.all["Free ads"];
    bool purchaseMade = entitlementInfo != null && entitlementInfo.isActive;
    if (Platform.isAndroid & !purchaseMade) {
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

  late Countdown model;

  void initState() {
    super.initState();
    loadAd();
    _getCountdown();
  }

  Future _getCountdown() async {
    setState(() {
      isLoading = true;
    });
    if (widget.id != null) {
      this.model = await db.find(widget.id) ?? Countdown();
    } else {
      model = Countdown();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isAdLoaded) {
          _interstitialAd.show();
        }
        return Future.value(true);
      },
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
          title: Text(
            AppLocalizations.of(context)!.newCountdown,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              color: Color(0xff4C5C68),
            ),
          ),
        ),
        body: isLoading
            ? null
            : Container(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 15, top: 30),
                                child: Text(
                                  AppLocalizations.of(context)!.wantTo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32,
                                    color: Color(0xff4C5C68),
                                  ),
                                ),
                              ),
                              TextFormField(
                                initialValue: model.type,
                                onSaved: (value) {
                                  model.type = value;
                                  debugPrint(model.type);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.emptyErrorMessage;
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                  color: Color(0xff4C5C68),
                                ),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppLocalizations.of(context)!.typePlaceholder,
                                    hintStyle: TextStyle(color: Color(0xff4C5C68).withOpacity(.5))),
                              ),
                              TextFormField(
                                initialValue: model.goal > 0 ? model.goal.toString() : '',
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  model.goal = int.tryParse(value ?? '') ?? 0;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.emptyErrorMessage;
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                  color: Color(0xff4C5C68),
                                ),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '4,5...',
                                    hintStyle: TextStyle(color: Color(0xff4C5C68).withOpacity(.5))),
                              ),
                              TextFormField(
                                initialValue: model.name,
                                onSaved: (value) {
                                  model.name = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.emptyErrorMessage;
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                  color: Color(0xff4C5C68),
                                ),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppLocalizations.of(context)!.namePlaceholder,
                                    hintStyle: TextStyle(color: Color(0xff4C5C68).withOpacity(.5))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            if (model.id != null) {
                              model.count = (model.goal < model.count) ? 0 : model.count;
                              db.update(model);
                            } else {
                              db.add(model);
                            }
                            if (_isAdLoaded) {
                              _interstitialAd.show();
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            Size(double.infinity, 40),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
