import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/AddAttendanceRes.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/AddDocRes.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/ChangePassRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/EditProfileReq.dart';
import 'package:mta/models/FectchProjectDocReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/SignupReq.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/models/NotificationRes.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/models/ProjectDetails.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/models/UserAccessreq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';    
// 
import 'package:retrofit/retrofit.dart';

import '../models/FetchCategoryUsersRes.dart';
part 'ApiService.g.dart';

// Run this code in termial to generate ApiService.g.dart file
// flutter packages pub run build_runner watch --delete-conflicting-outputs

 // @RestApi(baseUrl: "https://demo.emeetify.com:81/mta")

  @RestApi(baseUrl: "https://mta.multitechcorp.in/mta")
 //  @RestApi(baseUrl: "http://192.168.0.133:5777//mta")


abstract class ApiService 
{

  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

//////////////////////////////////////////////////////////////////////////////////////////
  /// Login and Signup Module
//////////////////////////////////////////////////////////////////////////////////////////

  @POST("/users/login")
  Future<LoginRes> login(@Body() LoginReq body);

  @POST("/users/publicusersignup")
  Future<ChangePassRes>signUp(@Body() SignUpReq body);

  @PUT("/users/{user_id}")
  Future<LoginRes> setPin(@Path("user_id") int id, @Body() SetPinReq body);

  @POST("/users/changePin")
  Future<LoginRes> setForgotPin(@Path("user_id") int id, @Body() SetPinReq body);
  
  @PUT("/projects/putCategory/{user_id}")
  Future<LoginRes> userAccess(@Path("user_id") String id, @Body() UserAccessReq body);

  @GET("/projects?user_id={user_id}")
  Future<DashboardRes> projects(@Path("user_id") int id);

  @GET("/newsfeed")
  Future<NewsRes> news();

  @GET("/users/profile/{user_id}")
  Future<ProfileRes> profile(@Path("user_id") int user_id);

  @GET(
      "/projects/getDocuments?category_id={category_id}&project_id={project_id}&users_id={users_id}")
  Future<FetchCategoryDocRes> getCategoryDoc(
      @Path("category_id") int id, @Path("project_id") int pid,@Path("users_id") int userid);

  @GET("/projects/getDocuments?project_id={project_id}&&users_id={users_id}")
  Future<FectchProjectDocRes> getProjectDoc(@Path("project_id") int id, @Path("users_id") int userid);

  @GET("/categories?project_id={project_id}")
  Future<FectchCatsRes> getCats(@Path("project_id") int id);

  @POST("/projects/addDocument")
  Future<AddDocRes> addDoc(@Body() AddDocReq body);

  @POST("/attendance")
  Future<AddAttendanceRes> addAttendance(@Body() AddAttendanceReq body);

  @GET("/attendance?user_id={user_id}&date={date}")
  Future<FetchAttendanceRes> getAttendance(
      @Path("user_id") int id, @Path("date") String date);


  @GET("/categories?project_id={project_id}")
  Future<FetchMapedCatRes> fetchCats(@Path("project_id") int id);

  @GET("/categories/getCatUsers?project_id={project_id}&category_id={category_id}")
  Future<FetchCategoryUsersRes> getCatUsers(@Path("project_id") int id,@Path("category_id") int catid);

  @GET("/projects/getmappedUser?project_id={project_id}")
  Future<FetchMapedUsersRes> fetchUsers(@Path("project_id") int id);

  @GET("/teams")
  Future<TeamsModel> fetchTeams(@Path("project_id") int id);

  @GET("/projects/getProjectsByTeam/{team_id}") 
  Future<DashboardRes> fetchProjectByTeams(@Path("team_id") int id);

  @GET("/projects/getProject/{project_id}")
  Future<ProjectDetailsRes> getProjectName(@Path("project_id") int id);

  @GET("/utils/getNotification")
  Future<NotificationRes> notification();


  @POST("/users/changePassword")
  Future<ChangePassRes> changePass(@Body() ChangePassReq body);

  @POST("/users/forgotPassword")
  Future<ChangePassRes> forgotPass(@Body() ForgotPassReq body);

  @POST("/users/validate_otp")
  Future<ChangePassRes> otpVerify(@Body() ValidateOTPReq body);

  @PUT("/users/{user_id}")
  Future<ChangePassRes> editProfile(
      @Path("user_id") int id, @Body() EditProfileReq body);

  @PUT("/utils/updateNotification/{noti_id}")
  Future<ChangePassRes> updateNotificationStatus(
      @Path("noti_id") int id);

  @DELETE("/users/removeImage/{user_id}")
  Future<ChangePassRes> removeProPic(
      @Path("user_id") int id);
     
  @DELETE("/users/{user_id}")
  Future<ChangePassRes> deleteUser(
      @Path("user_id") int id);

  @DELETE("/users/deleteDeviceId/{user_id}")
  Future<CommentsRes> removeDeviceId(
      @Path("user_id") int id);

     

  @POST("/utils/getAudioUrl")
  Future<AudioRes> uploadAudio(@Body() AudioReq body);

/////////////////////////////////////////////////////////////////////////////////////////
  /// Request and Response Body
//////////////////////////////////////////////////////////////////////////////////////////

  static ApiService create() 
  {
    final dio = Dio();
    try {
      print("trying dio");
      dio.interceptors.add(PrettyDioLogger());
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (options,handler) async 
          {
        options.headers["Content-Type"] = "application/json";
        options.headers["x-access-token"] = Strings.authToken;
        //options.headers["Host"] = "<calculated when request is sent>";
        options.followRedirects = false;
        options.validateStatus = (status) {
          Strings.statusCode = status!;
          if (status == 401) {
            Strings.isLogin = false;
            AppUtils.showToastError(
                "Session has been expired ! Please login again");
            navigatorKey.currentState?.popAndPushNamed('/verifypin');
            // return false;
          }
          return status < 500;
        };
        print("Printing api service");
       // print("dio api service-->${ApiService(dio)}");
        return handler.next(options);
       // return options;
      }));
      return ApiService(dio);
    } on DioError catch (error) {
      print("went inside error");
      print(error.error);
      return ApiService(dio);
    }
  }
}
