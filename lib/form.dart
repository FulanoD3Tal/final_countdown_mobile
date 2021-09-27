import 'package:flutter/material.dart';

import 'inputtext.dart';

class FormCountdown extends StatefulWidget {
  const FormCountdown({Key? key}) : super(key: key);

  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<FormCountdown> {
  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'New\ncountdown',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: Color(0xff4C5C68),
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Input(
                        label: 'Name',
                        required: true,
                      ),
                      Input(
                        label: 'Type',
                        required: true,
                      ),
                      Input(
                        label: 'Goal',
                        required: true,
                      ),
                      Input(
                        label: 'Description',
                        required: false,
                        textArea: true,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    Size(double.infinity, 40),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    Color(0xff1985A1),
                  ),
                ),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              )
            ],
          )),
    );
  }
}
