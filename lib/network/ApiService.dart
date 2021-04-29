import 'package:dio/dio.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/AddAttendanceRes.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/AddDocRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/utilities/strings.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

part 'ApiService.g.dart';

// Run this code in termial to generate ApiService.g.dart file
//flutter packages pub run build_runner watch --delete-conflicting-outputs

@RestApi(baseUrl: "https://demo.emeetify.com:81/mta")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

//////////////////////////////////////////////////////////////////////////////////////////
  /// Login and Signup Module
//////////////////////////////////////////////////////////////////////////////////////////

  @POST("/users/login")
  Future<LoginRes> login(@Body() LoginReq body);

  @PUT("/users/{user_id}")
  Future<LoginRes> setPin(@Path("user_id") int id, @Body() SetPinReq body);

  @GET("/projects")
  Future<DashboardRes> projects();

  @GET("/newsfeed")
  Future<NewsRes> news();

  @GET("/users/profile")
  Future<ProfileRes> profile();

  @GET(
      "/projects/getDocuments?category_id={category_id}&project_id={project_id}")
  Future<FetchCategoryDocRes> getCategoryDoc(
      @Path("category_id") int id, @Path("project_id") int pid);

  @GET("/projects/getDocuments?project_id={project_id}")
  Future<FectchProjectDocRes> getProjectDoc(@Path("project_id") int id);

  @GET("/categories?project_id={project_id}")
  Future<FectchCatsRes> getCats(@Path("project_id") int id);

  @POST("/projects/addDocument")
  Future<AddDocRes> addDoc(@Body() AddDocReq body);

  @POST("/attendance")
  Future<AddAttendanceRes> addAttendance(@Body() AddAttendanceReq body);

  @GET("/attendance?user_id={user_id}&date={date}")
  Future<FetchAttendanceRes> getAttendance(
      @Path("user_id") int id, @Path("date") String date);
/////////////////////////////////////////////////////////////////////////////////////////
  /// Request and Response Body
//////////////////////////////////////////////////////////////////////////////////////////

  static ApiService create() {
    final dio = Dio();
    try {
      dio.interceptors.add(PrettyDioLogger());
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
        options.headers["Content-Type"] = "application/json";
        options.headers["x-access-token"] = Strings.authToken;
        //options.headers["Host"] = "<calculated when request is sent>";
        options.followRedirects = false;
        options.validateStatus = (status) {
          return status < 500;
        };
        return options;
      }));
      return ApiService(dio);
    } on DioError catch (error) {
      print(error.error);
      return ApiService(dio);
    }
  }
}
