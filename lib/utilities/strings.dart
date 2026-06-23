import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';

import '../models/Chat/ChatNotificationRes.dart';

mixin Strings {
  static String testing = 'novalue';
  static bool fromNotificationComments = false;
  static bool fromNotificationDocuments = false;
  static bool fromNotificationChat = false;
  static bool fromNotificationNewMeeting = false;

  static bool fromForgotPassword = false;
  static String authToken = '';
  static bool fromReplies = false;
  static bool fromProjects = true;
  static String? basePath = '';

  // static String baseUrl = "https://demo.emeetify.com:81/mta";
  // static String baseUrl = "https://mta.multitechcorp.in/mta";
  static String baseUrl = "https://uatmta.multitechcorp.in/mta/";

  // static String socketUrl = 'https://demo.emeetify.com:5015/';

  // static String socketUrl = 'https://mta.multitechcorp.in:5022/';
  static String socketUrl = 'https://uatmta.multitechcorp.in:5022/';
//  static String socketUrl = 'http://192.168.0.134:5021/';

  // static String baseImageUrl = 'https://demo.emeetify.com:5032/';
  // static String baseImageUrl = 'https://mta.multitechcorp.in/mta-img/';
  static String baseImageUrl = 'https://uatmta.multitechcorp.in/mta-img/';

  static bool documentUploadfromProject = false;
  static bool internetDialog = false;
  static String? profilePic;
  static int? projectId;
  static int currentmenuvalue = 1;
  static int? userID;
  static int? courseID;
  static int? degreeID;
  static int? selectcourseID;
  static int? collegeID;
  static String? useremailID;
  static String selectstate = '';
  static String selectdistrict = '';
  static String selectcourse = '';
  static int? selectcontactno;
  static String? selectedImg;
  static bool? network;
  static int? roleId;
  static int statusCode = 0;
  static bool FromNotification = false;
  static bool pushNotify = true;
  static bool isLogin = false;
  static bool isPushAvailable = false;
  static int? docID = 0;

  static bool category = false;
  static List<Data> selectedProject = [];
  static List<FectchCatsData> selectedCategory = [];
  static List<FetchCategoryDoc> selectedCatDocument = [];
  static List<ProjectDocData> selectedProDocument = [];
  static ChatNotificationRes? chatNotificationResponse;

  static int selectedDocsIndex = 0;
  static int selectedCommentsIndex = 0;
  static List<CommentsRes> comments = [];
  static String fcmToken = "";
  static List<String> audioLoded = [];
  static List<CatsData> categories = [];
  static List<FetchMapedUsersData> users = [];
  static bool showNotification = false;
  // user data
  static String? username;
  static String? usermail;
  static int? whatsappno;
  static String? fathername;
  static String? place;
  static String? district;
  static String? dateofbirth;
  static String? preferedcourse;
  static String? pdfDoc;
  static int? selectedTeamId;
  static int? groupCreationAccess;

  static List<ProjectDocData> selectedNotifyDocument = [];
  static bool selectedNotifyDocumentFlag = false;

  static bool fromNotificationScren = false;

  static int? notificationID;
  static int? meetingID;

  static bool categoriesforReply = false;

  static bool fromNotificationReply = false;

  static var ctx;

  static bool fromTeamProjects = false;

  static int checkInRadius = 0;

  static String messageSelectionWarning =
      "You can only select upto 5 messages!";

  static bool isSelectionEnabled = false;

  static String locationLink = "https://www.google.com/maps?q=";

  static RegExp urlRegex = RegExp(
      r'^(?:http(s)?:\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)');

  static String googleAPIKey = "AIzaSyDIHhz8wDXVrLfu99G9q9pH05s_7918XQI";
}
