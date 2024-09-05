// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mta/screens/attendance/attendance.dart';
import 'package:mta/screens/chat/ChatScreen.dart';
import 'package:mta/screens/comments/comments.dart';
import 'package:mta/screens/doucument/viewdoclist.dart';
import 'package:mta/screens/meetings/meeting_details.dart';
import 'package:mta/screens/projectcomments/projectComments.dart';
import 'package:mta/screens/projectcomments/projectCommentsReplies.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/strings.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/ApiService.dart';
import '../screens/comments/replies.dart';

class AppUtils {
  // Field Focus

  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  /// Shared Preferences starts here
//////////////////////////////////////////////////////////////////////////////////////////

  static savePreferences(String key, dynamic value) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPrefs.setBool(key, value);
    } else if (value is String) {
      sharedPrefs.setString(key, value);
    } else if (value is int) {
      sharedPrefs.setInt(key, value);
    } else if (value is List<String>) {
      sharedPrefs.setStringList(key, value);
    }
  }

  static Future<String> getStringPreferences(String key) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String pref = sharedPrefs.getString(key) ?? "null";
    return pref;
  }

  static Future<int> getIntPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getInt(key) ?? 0;
  }

  static Future<bool> getBoolPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool(key) ?? false;
  }

  static Future<bool> clearPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.remove(key);
  }

  static Future<bool> clearAllPreferences() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.clear();
  }

  //  toast message

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Color(0xFF0061b0),
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  static void showToastError(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  static void showErrorSnackBar(context, String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String getFileExtension(String fileName) {
    var file = fileName.split(".");
    var fileExt = file[file.length - 1];
    if (fileExt == "png" || fileExt == "PNG") {
      return ".png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return ".jpg";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return ".pdf";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return ".txt";
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return ".mpg";
    } else if (fileExt == "mp4" || fileExt == "MP4") {
      return ".mp4";
    } else if (fileExt == "wav" || fileExt == "mp3") {
      return ".wav";
    } else if (fileExt == "m4a" || fileExt == "m4a") {
      return ".m4a";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return ".ppt";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return ".xls";
    } else {
      return ".doc";
    }
  }

  static String getFilTypeImg(String? fileName) {
    print("Filename--> $fileName");
    var file = fileName?.split("/");
    var fileExttemp = file?[file.length - 1];

    var finalSplit = fileExttemp?.split(".");
    var fileExt = finalSplit?[finalSplit.length - 1];

    print("exttt $fileExt");
    if (fileExt == "png" || fileExt == "PNG") {
      return "assets/icons/png.png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return "assets/icons/jpg.png";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return "assets/icons/pdf.png";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return "assets/icons/txt.png";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return "assets/icons/ppt.png";
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "mp4" || fileExt == "mkv") {
      return "assets/icons/mp4.png";
    } else if (fileExt == "wav" || fileExt == "mp3") {
      return "assets/icons/mp3.png";
    } else if (fileExt == "m4a") {
      return "assets/icons/aac.png";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return "assets/icons/xls.png";
    } else {
      return "assets/icons/doc.png";
    }
  }

  static Future<void> openFile(filePath) async {
    await OpenFilex.open(filePath);
  }

  static String formatDate(date) {
    var convertedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(convertedDate);
    return formatted;
  }

  static String getFileExt(String? fileName) {
    print("Filename--> $fileName");
    var file = fileName?.split("/");
    var fileExttemp = file?[file.length - 1];

    var finalSplit = fileExttemp?.split(".");
    var fileExt = finalSplit?[finalSplit.length - 1];

    print("exttt $fileExt");
    if (fileExt == "png" || fileExt == "PNG") {
      return "assets/icons/png.png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return "assets/icons/jpg.png";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return "assets/icons/pdf.png";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return "assets/icons/txt.png";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return "assets/icons/ppt.png";
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "mp4") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "wav" || fileExt == "mp3") {
      return "assets/icons/mp3.png";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return "assets/icons/xls.png";
    } else {
      return "assets/icons/doc.png";
    }
  }

  static findFilePath() async {
    String? basePath;
    if (Platform.isAndroid) {
      basePath = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr.length >= 5) {
        basePath = pathStr.substring(12, pathStr.length);
      }
      if (basePath != null && basePath.length >= 1) {
        basePath = basePath.substring(0, basePath.length - 1);
      }
    }
    Strings.basePath = basePath;
    print("base path $basePath");
    // return basePath;
  }

  static Future<bool?> updateDownloadStatus(msgId, context) async {
    final api = Provider.of<ApiService>(context, listen: false);
    var status = false;
    api.updateDownloadStatus(msgId, 1).then((response) {
      print("response ${response.status}");
      if (response.status!) {
        status = true;
        // AppUtils.showToastError("update status successfully");
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
        status = false;
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Unable to connect to server");
      print(onError.toString());
      status = false;
    });

    return status;
  }

  static void showToastErrorTop(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  static void showToastSuccess(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  // static void snackBar(BuildContext context, String message) {
  //   Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  // }

  static void showprogress() {
    // showProgressDialog(
    //     backgroundColor: Colors.white.withOpacity(0),
    //     textStyle: TextStyle(color: Colors.black));
    print('showProgress');
    EasyLoading.show();
  }

  static void showprogresswithpercent(double percent) {
    // showProgressDialog(
    //     backgroundColor: Colors.white.withOpacity(0),
    //     textStyle: TextStyle(color: Colors.black));
    print('showProgress');
    EasyLoading.showProgress(percent,
        status: "Downloading ${(percent * 100).toStringAsFixed(0) + "%"}");
  }

  static void showUploadProgressWithPercent(double percent) {
    // showProgressDialog(
    //     backgroundColor: Colors.white.withOpacity(0),
    //     textStyle: TextStyle(color: Colors.black));
    print('showProgress');
    EasyLoading.showProgress(percent,
        status:
            "Please wait, while your file are being uploaded ${(percent * 100).toStringAsFixed(0) + "%"}");
  }

  static void dismissprogress() {
    //dismissProgressDialog();
    print('dismiss');

    EasyLoading.dismiss();
  }

  static void removeDeviceId(ctx) {
    final api = Provider.of<ApiService>(ctx!, listen: false);
    AppUtils.getIntPreferences('userId').then((value) {
      if (value != null) {
        api
            .removeDeviceId(Strings.userID!)
            .then((response) {})
            .catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      }
    });
  }

  String getMeetingDateFormat(start, end) {
    final startDate = DateTime.parse(start);
    final endDate = DateTime.parse(end);

    final formatter = DateFormat('MMMM dd, yyyy | hh:mm a');
    final formattedStartDate = formatter.format(startDate);

    final timeFormatter = DateFormat('hh:mm a');
    final formattedEndTime = timeFormatter.format(endDate);

    final result = '$formattedStartDate - $formattedEndTime';
    return result;
  }

  String getMeetingType(type) {
    return type == "1"
        ? "Inperson Meeting"
        : type == "2"
            ? "Virtual Meeting"
            : "Phone Call";
  }

  redirectFromNotification() {
    if (Strings.FromNotification) {
      Strings.FromNotification = false;
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => Attendance()));
    } else if (Strings.fromNotificationComments) {
      if (Strings.selectedProDocument[0].projectComments == "true") {
        if (Strings.selectedProDocument[0].commentId == null) {
          navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (context) => ProjectComments()));
        } else {
          navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => ProjectCommentsReplies()));
        }
      } else {
        if (Strings.selectedProDocument[0].commentId == null) {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => Comments()));
        } else {
          navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => Replies()));
        }
      }
    } else if (Strings.fromNotificationDocuments) {
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => ViewDocScreen()));
    } else if (Strings.fromNotificationChat) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            teamName: Strings.chatNotificationResponse?.groupName ?? "0",
            groupId:
                int.parse(Strings.chatNotificationResponse?.groupId ?? "0"),
            teamId: int.parse(Strings.chatNotificationResponse?.teamId ?? "0"),
            projectId:
                int.parse(Strings.chatNotificationResponse?.projectId ?? "0"),
          ),
        ),
        (route) => false,
      );
    } else if (Strings.fromNotificationNewMeeting) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MeetingDetails(
                  meeting_id: Strings.meetingID!,
                  fromHistory: false,
                )),
        (route) => false,
      );
    } else {
      if (Strings.roleId == 6) {
        navigatorKey.currentState?.pushNamed("/projects");
      } else {
        navigatorKey.currentState?.pushNamed("/teamsDashboard");
      }
    }
  }
}
