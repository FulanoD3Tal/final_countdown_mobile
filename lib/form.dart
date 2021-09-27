import 'package:flutter/material.dart';

import 'inputtext.dart';
import './models/countdown.dart';

class FormCountdown extends StatefulWidget {
  const FormCountdown({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final Function(Countdown) onSubmit;

  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<FormCountdown> {
  final _formKey = GlobalKey<FormState>();
  Countdown model = Countdown();

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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Input(
                        label: 'Name',
                        required: true,
                        onSaved: (value) {
                          model.name = value;
                        },
                      ),
                      Input(
                        label: 'Type',
                        required: true,
                        onSaved: (value) {
                          model.type = value;
                        },
                      ),
                      Input(
                        label: 'Goal',
                        required: true,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          model.count = int.tryParse(value ?? '') ?? 0;
                        },
                      ),
                      Input(
                        label: 'Description',
                        required: false,
                        textArea: true,
                        onSaved: (value) {
                          model.description = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onSubmit(model);
                    Navigator.pop(context);
                  }
                },
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
          ),
        ),
      ),
    );
  }
}
