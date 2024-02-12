import 'package:mta/screens/Webview/webview.dart';
import 'package:mta/screens/attendance/attendance.dart';
import 'package:mta/screens/authentication/otpverification.dart';
import 'package:mta/screens/authentication/setpin.dart';
import 'package:mta/screens/authentication/verifypin.dart';
import 'package:mta/screens/categories/categeories.dart';
import 'package:mta/screens/categories/categoriesinfo.dart';
import 'package:mta/screens/chat/ChatGroups.dart';
import 'package:mta/screens/comments/adddocComments.dart';
import 'package:mta/screens/comments/comments.dart';
import 'package:mta/screens/comments/replies.dart';
import 'package:mta/screens/dashboard/teamsDashboard.dart';
import 'package:mta/screens/others/contactus.dart';
import 'package:mta/screens/dashboard/dashboard.dart';
import 'package:mta/screens/doucument/adddoc.dart';
import 'package:mta/screens/doucument/viewdoclist.dart';
import 'package:mta/screens/drawer/drawer.dart';
import 'package:mta/screens/others/newshighlights.dart';
import 'package:mta/screens/others/notification.dart';
import 'package:mta/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:mta/screens/projectcomments/projectComments.dart';
import 'package:mta/screens/projectcomments/projectCommentsReplies.dart';
import 'package:mta/screens/projects/projects.dart';
import 'package:mta/screens/splashscreen.dart';

import '../screens/authentication/login.dart';

class RoutesGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final arg = settings.arguments;
    switch (settings.name) 
    {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
        break;
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => Dashboard());
        break;
      case '/teamsDashboard':
        return MaterialPageRoute(builder: (_) => TeamsDashboard());
        break;
      case '/projects':
        return MaterialPageRoute(builder: (_) => Projects());
        break;
      case '/webview':
        return MaterialPageRoute(builder: (_) => WebpageView());
        break;
      case '/otpverification':
        return MaterialPageRoute(builder: (_) => Otpverification());
        break;
      case '/setpin':
        return MaterialPageRoute(builder: (_) => Setpin());
        break;
      case '/drawer':
        return MaterialPageRoute(builder: (_) => HomeScreen());
        break;
      case '/categories':
        return MaterialPageRoute(builder: (_) => Categories());
        break;
      case '/categoriesinfo':
        return MaterialPageRoute(builder: (_) => CategoriesInfo());
        break;
      case '/profile':
        return MaterialPageRoute(builder: (_) => Profile());
        break;
      case '/comments':
        return MaterialPageRoute(builder: (_) => Comments());
        break;
      case '/replies':
        return MaterialPageRoute(builder: (_) => Replies());
        break;
      case '/adddoc':
        return MaterialPageRoute(builder: (_) => AddDoc());
        break;
      case '/attendance':
        return MaterialPageRoute(builder: (_) => Attendance());
        break;
      case '/verifypin':
        return MaterialPageRoute(builder: (_) => Verifypin());
        break;
      case '/viewdoclist':
        return MaterialPageRoute(builder: (_) => ViewDocScreen());
        break;
      case '/contactus':
        return MaterialPageRoute(builder: (_) => Contactus());
        break;
      case '/newshighlights':
        return MaterialPageRoute(builder: (_) => Newshighlights());
        break;
      case '/notification':
        return MaterialPageRoute(builder: (_) => PushNotification());
        break;
      case '/adddocComments':
        return MaterialPageRoute(builder: (_) => AddDocComments());
        break;
      case '/projectComments':
        return MaterialPageRoute(builder: (_) => ProjectComments());
        break;
      case '/projectCommentReplies':
        return MaterialPageRoute(builder: (_) => ProjectCommentsReplies());
        break;
      // case '/chatGroups':
      //   return MaterialPageRoute(builder: (_) => ChatGroups());
      //   break;
      default:
        return _errorRoute();
        break;
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
