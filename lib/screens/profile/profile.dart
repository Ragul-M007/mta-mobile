import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/EditProfileReq.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io' as Io;

FocusNode name = new FocusNode();
ImagePicker _picker = ImagePicker();

class Profile extends StatefulWidget {
  static const String routeName = "/profile";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showExitDialog(BuildContext ctx) {
    return showDialog<void>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text(
          "Are you sure ?",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Do you want to exit an App',
          style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: Text(
              'Yes',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showExitDialog(context);
        return false;
      },
      child: Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: SafeArea(
          child: Scaffold(
            drawer: AppDrawer(),
            backgroundColor: Colors.grey[300],
            appBar: EmptyAppBar(),
            body: ProfileContent(),
          ),
        ),
      ),
    );
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      //Navigator.popAndPushNamed(context, routename);
      Strings.isLogin = false;
      Navigator.popAndPushNamed(context, "/login");
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename!);
    }
  }
}

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final mobileField = TextEditingController();
  final userType = TextEditingController();
  final password = TextEditingController();
  final changePassConfirm = TextEditingController();
  final changePassNew = TextEditingController();
  final changePassOld = TextEditingController();
  final editNumber = TextEditingController();
  final editAddress = TextEditingController();
  final editName = TextEditingController();
  final editState = TextEditingController();
  final editCity = TextEditingController();

  List<ProfileData> _profileData = [];
  bool loader = true;

  String? codeVerifyField;
  String? verificationCode;

  FocusNode one = new FocusNode();
  FocusNode two = new FocusNode();
  FocusNode three = new FocusNode();
  FocusNode four = new FocusNode();

  var oneT = TextEditingController();
  var twoT = TextEditingController();
  var threeT = TextEditingController();
  var fourT = TextEditingController();

  BuildContext? ctx;

  var address = '';
  var editPicTap = false;
  var removeImage = false;
  bool _cameraInProgress = false;
  var editProfilePictureBase64 = '';
  Uint8List? editProfilePicture;

  MemoryImage? _imageAsyncWidget;

  @override
  void initState() {
    setState(() {
      mobileField.text = "";
      userType.text = "";
    });
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => getProfile());
    getProfile();
    fillData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: loader
              ? Padding(padding: EdgeInsets.all(0.0))
              : Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * .32,
                      decoration: BoxDecoration(
                        color: Color(0xFF0061b0),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Strings.profilePic == ""
                                  ? CircleAvatar(
                                      backgroundImage: AssetImage(
                                        "assets/icons/account.png",
                                      ),
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2),
                                    )
                                  : image(
                                      Strings.baseImageUrl +
                                          Strings.profilePic!,
                                      40.0,
                                      40.0),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profileData[0].name!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _profileData[0].email!,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _editProfile();
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(50.0)),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Color(0xFF0061b0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0, MediaQuery.of(context).size.height * .32, 0, 0),
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Builder(
                              builder: (ctx) => GestureDetector(
                                onTap: () => Scaffold.of(ctx).openDrawer(),
                                child: Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Profile",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                    (_profileData[0].city! != "" &&
                            _profileData[0].state! != "")
                        ? Container(
                            margin: EdgeInsets.fromLTRB(
                                20,
                                MediaQuery.of(context).size.height * .25,
                                20,
                                10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                                padding: EdgeInsets.all(30),
                                child: Row(
                                  children: [
                                    Icon(Icons.pin_drop),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Text(
                                        address,
                                        overflow: TextOverflow.clip,
                                      ),
                                    )
                                  ],
                                )),
                          )
                        : SizedBox(),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.fromLTRB(10,
                            MediaQuery.of(context).size.height * .40, 10, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: TextStyle(
                                  color: Color(0xFF0061b0),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: mobileField,
                              enabled: false,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.call,
                                      color: Color(0xFF0061b0))),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Role",
                              style: TextStyle(
                                  color: Color(0xFF0061b0),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: userType,
                              enabled: false,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person,
                                      color: Color(0xFF0061b0))),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                _changePass();
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Change Password",
                                    style: TextStyle(
                                        color: Color(0xFF0061b0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: new BoxDecoration(
                                      color: Color(0xFF0061b0),
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(50.0)),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                _changePin();
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Reset Pin",
                                    style: TextStyle(
                                        color: Color(0xFF0061b0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: new BoxDecoration(
                                      color: Color(0xFF0061b0),
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(50.0)),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => new AlertDialog(
                                    title: Text(
                                      "Are you sure want to delete the account?",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF0061b0),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    content: Text(
                                      'Deleting the account will remove all your data.',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: new Text(
                                          'No',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          removeUser(context);
                                        },
                                        child: new Text(
                                          'Yes',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Delete Account",
                                    style: TextStyle(
                                        color: Color(0xFF0061b0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: new BoxDecoration(
                                      color: Color(0xFF0061b0),
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(50.0)),
                                    ),
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                )),
    );
  }

  fillData() {
    oneT.clear();
    twoT.clear();
    threeT.clear();
    fourT.clear();
  }

  static void removeUser(ctx) {
    final api = Provider.of<ApiService>(ctx!, listen: false);
    AppUtils.getIntPreferences('userId').then((value) {
      if (value != null) {
        api.deleteUser(value).then((response) {
          if (response.status!) {
            AppUtils.showToastSuccess(response.message!);
            AppUtils.clearAllPreferences();
            Strings.isLogin = false;
            Navigator.popAndPushNamed(ctx!, "/login");
          } else {
            AppUtils.showToastError(response.message!);
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      }
    });
  }

  getProfile() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.profile(Strings.userID!).then((response) {
      AppUtils.dismissprogress();
      print('profileResponse status ${response.data}');

      setState(() {
        loader = false;
        print("response----> ${response.data}");
        _profileData = response.data!;
        mobileField.text = _profileData[0].mobileNo!;
        userType.text = _profileData[0].role!;
        if (Strings.roleId == 7) {
          address = _profileData[0].city! + " , " + _profileData[0].state!;
        } else {
          address = _profileData[0].area! +
              " , " +
              _profileData[0].city! +
              " , " +
              _profileData[0].state!;
        }

        editNumber.text = _profileData[0].mobileNo!;
        editName.text = _profileData[0].name!;
        editAddress.text = _profileData[0].area!;
        editState.text = _profileData[0].state!;
        editCity.text = _profileData[0].city!;
        if (_profileData[0].userImg != null) {
          Strings.profilePic = _profileData[0].userImg!;
        } else {
          Strings.profilePic = "";
        }
        print("check");
      });
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  Widget _loader() {
    return Container(
      width: MediaQuery.of(context).size.width, //70.0,
      height: MediaQuery.of(context).size.height * 86,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget image(String img, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        image: new DecorationImage(
          image: new NetworkImage(img),
          fit: BoxFit.fill,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
      ),
    );
  }

  Future<void> _changePass() async {
    changePassOld.clear();
    changePassNew.clear();
    changePassConfirm.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctxd) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(ctxd).pop();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(ctxd).size.width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          new Icon(Icons.close,
                              size: 22.0, color: Colors.black),
                        ],
                      ),
                    ),
                    Text(
                      "Old Password",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: changePassOld,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "New Password",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: changePassNew,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: changePassConfirm,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        _changePassSave();
                      },
                      child: Container(
                        child: Center(
                            child: Text(
                          "SAVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                        width: MediaQuery.of(ctxd).size.width * 0.8,
                        height: 40,
                        margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                        decoration: BoxDecoration(
                            color: Color(0xFF0061b0),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  Future<void> _changePin() async {
    oneT.clear();
    twoT.clear();
    threeT.clear();
    fourT.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextResetPin) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(contextResetPin).pop();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(contextResetPin).size.width * 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            new Icon(Icons.close,
                                size: 22.0, color: Colors.black),
                          ],
                        ),
                      ),
                      Text(
                        "Reset your 4 digit secret pin to your application",
                        style: TextStyle(color: const Color(0xFF9e9e9e)),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      _boxBuilder(context),
                      // PinFieldAutoFill(
                      //     cursor: Cursor(
                      //       width: 2,
                      //       height: 40,
                      //       color: Colors.blue,
                      //       radius: Radius.circular(1),
                      //       enabled: true,
                      //     ),
                      //     decoration: UnderlineDecoration(
                      //       textStyle:
                      //           TextStyle(fontSize: 20, color: Colors.black),
                      //       colorBuilder: FixedColorBuilder(
                      //           Colors.black.withOpacity(0.3)),
                      //     ),
                      //     autoFocus: true,
                      //     onCodeSubmitted: (String code) {
                      //       if (codeVerifyField!.length < 4) {
                      //         AppUtils.showToastError(
                      //             "Please enter 4 digit Pin");
                      //       } else {
                      //         resetPin(contextResetPin);
                      //       }
                      //     }, //code submitted callback
                      //     onCodeChanged: (String? code) {
                      //       codeVerifyField = code;
                      //     }, //code changed callback
                      //     codeLength: 4),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          codeVerifyField =
                              oneT.text + twoT.text + threeT.text + fourT.text;
                          print(codeVerifyField);
                          if (codeVerifyField!.length < 4) {
                            AppUtils.showToastError("Please enter 4 digit Pin");
                          } else {
                            resetPin(contextResetPin);
                          }
                        },
                        child: Container(
                          child: Center(
                              child: Text(
                            "SAVE",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                          width:
                              MediaQuery.of(contextResetPin).size.width * 0.8,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                          decoration: BoxDecoration(
                              color: Color(0xFF0061b0),
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      )
                    ],
                  )),
            ),
          );
        });
      },
    );
  }

  Widget _boxBuilder(contextResetPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _box(1, contextResetPin),
        _box(2, contextResetPin),
        _box(3, contextResetPin),
        _box(4, contextResetPin),
      ],
    );
  }

  Widget _box(val, contextResetPin) {
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
          autofocus: val == 1,
          controller: val == 1
              ? oneT
              : val == 2
                  ? twoT
                  : val == 3
                      ? threeT
                      : fourT,
          focusNode: val == 1
              ? one
              : val == 2
                  ? two
                  : val == 3
                      ? three
                      : four,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), counterText: ''),
          textAlign: TextAlign.center,
          onChanged: (value) {
            print(value);
            print("inside");
            if (value == '') {
              FocusScope.of(contextResetPin).requestFocus(
                val == 4
                    ? three
                    : val == 3
                        ? two
                        : val == 2
                            ? one
                            : null,
              );
            } else {
              FocusScope.of(contextResetPin).requestFocus(
                val == 1
                    ? two
                    : val == 2
                        ? three
                        : val == 3
                            ? four
                            : null,
              );
            }
          },
        ),
      ),
    );
  }

  _changePassSave() {
    if (changePassOld.text.trim() == "") {
      AppUtils.showToastError("Please enter Old Password");
    } else if (changePassNew.text.trim() == "") {
      AppUtils.showToastError("Please enter New Password");
    } else if (changePassConfirm.text.trim() == "") {
      AppUtils.showToastError("Please enter Confirm Password");
    } else if (changePassNew.text.trim() != changePassConfirm.text.trim()) {
      AppUtils.showToastError(
          "New Password & Confirm Password are not matching");
    } else {
      AppUtils.showprogress();
      final api = Provider.of<ApiService>(context, listen: false);
      ChangePassReq request = ChangePassReq();
      request.emailId = _profileData[0].email;
      request.newPassword = changePassNew.text;
      request.password = changePassOld.text;
      var dat = jsonEncode(request);
      print(dat);
      api.changePass(request).then((response) {
        AppUtils.dismissprogress();
        print('Response status ${response.toJson()}');
        if (response.status!) {
          AppUtils.showToastSuccess(response.message!);
          AppUtils.clearAllPreferences();
          Strings.isLogin = false;
          Navigator.popAndPushNamed(context, "/login");
        } else {
          AppUtils.showToastError(response.message!);
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }

  Future<void> _editProfile() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      editPicTap = false;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(ctx).size.width * 0.75,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              new Icon(Icons.close,
                                  size: 22.0, color: Colors.black),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: editPicTap == false
                                  ? (Strings.profilePic == ""
                                      ? CircleAvatar(
                                          child: Image.asset(
                                              "assets/icons/account.png"),
                                          radius: 40,
                                          backgroundColor:
                                              Colors.grey.withOpacity(0.3),
                                        )
                                      : image(
                                          Strings.baseImageUrl +
                                              Strings.profilePic!,
                                          80.0,
                                          80.0))
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      decoration: new BoxDecoration(
                                        color: const Color(0xff7c94b6),
                                        image: new DecorationImage(
                                          image: _imageAsyncWidget!,
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: new BorderRadius.all(
                                            new Radius.circular(50.0)),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    takePhoto(ImageSource.camera, setState);
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 20, color: Color(0xFF0061b0)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Camera",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    pickImage(ImageSource.gallery, setState);
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.collections,
                                            size: 20, color: Color(0xFF0061b0)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    //changeProPic();
                                    //takePhoto(ImageSource.gallery);
                                    //removeImage = true;
                                    //_editProfileSave(context);

                                    setState(() {
                                      //editPicTap = false;
                                      removeImage = true;
                                      Strings.profilePic = "";
                                    });
                                    // removeProPic();
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 20, color: Color(0xFF0061b0)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Delete Image",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Name",
                          style: TextStyle(
                              color: Color(0xFF0061b0),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          focusNode: name,
                          controller: editName,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z]")),
                          ],
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person,
                                  size: 14, color: Color(0xFF0061b0))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Phone Number",
                          style: TextStyle(
                              color: Color(0xFF0061b0),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          controller: editNumber,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.call,
                                  size: 14, color: Color(0xFF0061b0))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "State",
                          style: TextStyle(
                              color: Color(0xFF0061b0),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: editState,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.home,
                                  size: 14, color: Color(0xFF0061b0))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "City",
                          style: TextStyle(
                              color: Color(0xFF0061b0),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: editCity,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_city,
                                  size: 14, color: Color(0xFF0061b0))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Address",
                          style: TextStyle(
                              color: Color(0xFF0061b0),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: editAddress,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_pin,
                                  size: 14, color: Color(0xFF0061b0))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            _editProfileSave(ctx);
                          },
                          child: Container(
                            child: Center(
                                child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                            width: MediaQuery.of(ctx).size.width * 0.8,
                            height: 40,
                            margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                            decoration: BoxDecoration(
                                color: Color(0xFF0061b0),
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
      },
    );
  }

  _editProfileSave(ctxt) {
    if (editName.text.trim() == "") {
      AppUtils.showToastError("Please enter your Name");
    } else if (editNumber.text.trim() == "") {
      AppUtils.showToastError("Please enter your Phone Number");
    } else if (editState.text.trim() == "") {
      AppUtils.showToastError("Please enter your State");
    } else if (editCity.text.trim() == "") {
      AppUtils.showToastError("Please enter your City");
    } else if (editAddress.text.trim() == "") {
      AppUtils.showToastError("Please enter your Address");
    } else {
      AppUtils.showprogress();
      final api = Provider.of<ApiService>(context, listen: false);
      EditProfileReq request = EditProfileReq();
      request.name = editName.text;
      request.mobileNo = editNumber.text;
      request.area = editAddress.text;
      request.city = editCity.text;
      request.state = editState.text;
      if (editPicTap == true) {
        request.userImg = editProfilePictureBase64;
      }

      print(request.name);
      print(request.mobileNo);
      print(request.area);
      print(request.city);
      print(request.state);
      print(request.userImg);
      var dat = jsonEncode(request);

      print(dat);
      api.editProfile(Strings.userID!, request).then((response) {
        AppUtils.dismissprogress();
        print('Response status ${response.toJson()}');
        if (response.status!) {
          AppUtils.showToastSuccess(response.message!);

          if (removeImage == true) {
            print("removeImage");
            removeProPic();
          } else {
            Navigator.of(ctxt).pop();
            getProfile();
          }
        } else {
          AppUtils.showToastError(response.message!);
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }

  Future<void> changeProPic() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'JPG', 'jepg', 'png', 'PNG'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      final bytes = await Io.File(file.path!).readAsBytes();
      setState(() {
        String base64Encodes(List<int> bytes) => base64.encode(bytes);
        String base64Encode = base64Encodes(bytes); //base64.encode(bytes);
        editProfilePictureBase64 =
            "data:image/" + file.extension! + ";base64," + base64Encode;
        editProfilePicture = base64.decode(base64Encode);
        editPicTap = true;
        _imageAsyncWidget = new MemoryImage(editProfilePicture!);
        name.requestFocus();
        // name.dispose();
      });
    } else {
      // User canceled the picker
    }
  }

  void takePhoto(ImageSource source, StateSetter dialogSetState) async {
    if (_cameraInProgress) return;
    _cameraInProgress = true;
    try {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        AppUtils.showToastError(
            "Please enable Camera from App permission Settings");
        return;
      }
      if (!status.isGranted) return;
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      final bytes = await Io.File(pickedFile.path).readAsBytes();
      dialogSetState(() {
        editProfilePictureBase64 =
            "data:image/jpeg;base64," + base64Encode(bytes);
        editProfilePicture = base64.decode(base64Encode(bytes));
        editPicTap = true;
        _imageAsyncWidget = new MemoryImage(editProfilePicture!);
      });
    } finally {
      _cameraInProgress = false;
    }
  }

  void pickImage(ImageSource source, StateSetter dialogSetState) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;
    final bytes = await Io.File(pickedFile.path).readAsBytes();
    dialogSetState(() {
      editProfilePictureBase64 =
          "data:image/jpeg;base64," + base64Encode(bytes);
      editProfilePicture = base64.decode(base64Encode(bytes));
      editPicTap = true;
      _imageAsyncWidget = new MemoryImage(editProfilePicture!);
    });
  }

  resetPin(contextpin) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    SetPinReq setpinreq = SetPinReq();
    setpinreq.loginpin = codeVerifyField;
    codeVerifyField = "";
    AppUtils.getIntPreferences('userId').then((value) {
      if (value != null) {
        api.setPin(value, setpinreq).then((response) {
          AppUtils.dismissprogress();

          if (response.status!) {
            AppUtils.showToastSuccess(response.message!);
            AppUtils.savePreferences("easyAccess", "Y");
            Navigator.of(contextpin).pop();
            // Navigator.popAndPushNamed(context, "/verifypin");
            oneT.text = '';
            twoT.text = '';
            threeT.text = '';
            fourT.text = '';
          } else {
            AppUtils.showToastError(response.message!);
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      }
    });
  }

  removeProPic() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.removeProPic(Strings.userID!).then((response) {
      if (response.status!) {
        AppUtils.dismissprogress();
        Navigator.of(context).pop();
        getProfile();
        AppUtils.showToast("Profile picture removed Successfully.");
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
