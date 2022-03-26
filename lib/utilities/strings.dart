import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';

mixin Strings 
{
  static String authToken = '';
  //static String baseImageUrl = "https://demo.emeetify.com:81/";
  static String socketUrl = 'https://demo.emeetify.com:5012/';
  //static String socketUrl = 'https://demo.emeetify.com:81/';
  static String imageUrl = 'https://demo.emeetify.com:5016/';
  static String baseImageUrl = 'https://mta.multitechcorp.in/mta-img/';


  static String? profilePic;
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
  static int selectedDocsIndex = 0;
  static int selectedCommentsIndex = 0;
  static List<CommentsRes> comments = [];
  static String fcmToken = "";
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

  static List<ProjectDocData> selectedNotifyDocument = [];
  static bool selectedNotifyDocumentFlag = false;
}
