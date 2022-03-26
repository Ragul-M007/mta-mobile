import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/router.dart';


Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}
Future<void> main() async {
  //_setupLogging();
  // runApp(SplashScreen());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(SplashScreen());
    configLoading();

    // runApp(MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(
    //       primarySwatch: MyColors.navy,
    //       primaryColor: Color(0xFF8686f1),
    //       visualDensity: VisualDensity.adaptivePlatformDensity,
    //     ),
    //     initialRoute: '/',
    //     onGenerateRoute: RoutesGenerator.generateRoute,
    //     home: SplashScreen()));
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 25.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  //..customAnimation = CustomAnimation();
}
// void _setupLogging() {
//   Logger.root.level = Level.ALL;
//   Logger.root.onRecord.listen((rec) {
//     print('resapi call>> ${rec.level.name}: ${rec.time}: ${rec.message}');
//   });
// }
