import 'package:final_coutdown/form.dart';
import 'package:flutter/material.dart';

import 'db_helpers/sqlite_helper.dart';
import 'models/countdown.dart';

class DetailCountdown extends StatefulWidget {
  final countdownId;
  const DetailCountdown({
    Key? key,
    required this.countdownId,
  }) : super(key: key);

  @override
  _DetailCountdownState createState() => _DetailCountdownState();
}

class _DetailCountdownState extends State<DetailCountdown> {
  final db = CountdownProvider.instance;
  late Countdown? countdown;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Color(0xffFFFFFF),
        leading: IconButton(
            onPressed: () {
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.15),
                    height: size.height - (size.height * 0.15),
                    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 60),
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
                            Text(
                              (countdown!.goal - countdown!.count) == 0
                                  ? '${countdown?.type} finished'
                                  : '${countdown?.type} left of ${countdown?.goal}',
                              style: TextStyle(
                                color: Color(0xff4C5C68),
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: (countdown!.goal - countdown!.count) == 0
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
                                      'remove one'.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 64),
                          child: Text(
                            countdown?.name ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff4C5C68),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            countdown?.description ?? '',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff4C5C68),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 55),
                              child: count(),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
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
                  Text('Delete'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await db.delete(countdownId);
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
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
