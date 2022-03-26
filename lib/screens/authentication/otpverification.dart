import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Otpverification extends StatefulWidget {
  static const String routeName = "/otpverification";

  @override
  _OtpverificationState createState() => _OtpverificationState();
}

class _OtpverificationState extends State<Otpverification> 
{
  final mobileField = TextEditingController();
  String? codeVerifyField;
  String? verificationCode;

  bool _isLoading = false;
  bool isVerifyScreen = false;

  FocusNode one = new FocusNode();
  FocusNode two = new FocusNode();
  FocusNode three = new FocusNode();
  FocusNode four = new FocusNode();
  FocusNode five = new FocusNode();
  FocusNode six = new FocusNode();
  final oneT = TextEditingController();
  final twoT = TextEditingController();
  final threeT = TextEditingController();
  final fourT = TextEditingController();
  final fiveT = TextEditingController();
  final sixT = TextEditingController();
  _goDashboard() {}

  Future<void> verifyPhone() async {
    setState(() {
      _isLoading = true;
    });
  }

  signin() {}

  _login() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .35,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: new DecorationImage(
              image: new AssetImage("assets/images/background1.png"),
              fit: BoxFit.fill,
            ),
          ),
          padding: EdgeInsets.all(10),
          width: double.infinity,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height * .35, 0, 0),
          padding: EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200]
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * .22, 20, 10),
          width: double.infinity,
          height:MediaQuery.of(context).size.height * .7 ,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 54,
                ),
                
                 Text("Otp Verification",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                SizedBox(
                  height: 50,
                ),
                 Text("Enter 4 digit code that has been sent to \nregistered mobile number",
                      style: TextStyle(),
                    ),
                SizedBox(
                  height: 5.0,
                ),
                _boxBuilder(),
                SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : Container(
                        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(15),
                              onPressed: () {
                                print(
                                    "${oneT.text} ${twoT.text} ${threeT.text} ${fourT.text} ${fiveT.text} ${sixT.text}");
                                codeVerifyField = oneT.text +
                                    twoT.text +
                                    threeT.text +
                                    fourT.text +
                                    fiveT.text +
                                    sixT.text;
                                print(codeVerifyField);
                                print("${codeVerifyField!.length}");
                                if (codeVerifyField!.length < 6) {
                                } else {
                                  signin();
                                }
                              },
                              child: Text(
                                "Submit",
                              ),
                              color: Colors.blue),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    )));
  }

  Widget _boxBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _box(1),
        _box(2),
        _box(3),
        _box(4),
        _box(5),
        _box(6),
      ],
    );
  }

  Widget _box(val) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        height: 50,
        width: 40,
        child: TextField(
          keyboardType: TextInputType.number,
          maxLength: 1,
          autofocus: true,
          controller: val == 1
              ? oneT
              : val == 2
                  ? twoT
                  : val == 3
                      ? threeT
                      : val == 4
                          ? fourT
                          : val == 5
                              ? fiveT
                              : sixT,
          focusNode: val == 1
              ? one
              : val == 2
                  ? two
                  : val == 3
                      ? three
                      : val == 4
                          ? four
                          : val == 5
                              ? five
                              : six,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), counterText: ''),
          textAlign: TextAlign.center,
          onChanged: (value) {
            print(value);
            if (value == '') {
              print("null");
            } else {
              FocusScope.of(context).requestFocus(
                val == 1
                    ? two
                    : val == 2
                        ? three
                        : val == 3
                            ? four
                            : val == 4
                                ? five
                                : val == 5
                                    ? six
                                    : null,
              );
              print("not null");
            }
          },
        ),
      ),
    );
  }
}
