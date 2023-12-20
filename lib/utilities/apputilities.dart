
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mta/utilities/strings.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/ApiService.dart';

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

  static savePreferences(String key, dynamic value) async 
  {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPrefs.setBool(key, value);
    } else if (value is String) {
      sharedPrefs.setString(key, value);
    } else if (value is int) {
      sharedPrefs.setInt(key, value);
    } else if (value is List<String>) 
    {
      sharedPrefs.setStringList(key, value);
    }
  }

  static Future<String> getStringPreferences(String key) async 
  {
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
        gravity: ToastGravity.CENTER,
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

static  String getFileExtension(String fileName) {
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
    }
    else if (fileExt == "ppt" || fileExt == "PPT") {
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

 static String getFilTypeImg(String? fileName) 
  {
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

static Future<void> openFile(filePath) async {
    await OpenFilex.open(filePath);
  }

 static Future<String?> findFilePath()
async {
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
      print("base path $basePath");
    return basePath;
}

  static void showToastErrorTop(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
        fontSize: 16.0);
  }

  static void showToastSuccess(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        gravity: ToastGravity.CENTER,
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
    EasyLoading.showProgress(percent,status: "Downloading ${(percent * 100).toStringAsFixed(0) + "%"}");
  }

  static void showUploadProgressWithPercent(double percent) {
    // showProgressDialog(
    //     backgroundColor: Colors.white.withOpacity(0),
    //     textStyle: TextStyle(color: Colors.black));
    print('showProgress');
    EasyLoading.showProgress(percent,status: "Please wait, while your file are being uploaded ${(percent * 100).toStringAsFixed(0) + "%"}");
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
        api.removeDeviceId(Strings.userID!).then((response) {

        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      }
    });
  }
}
