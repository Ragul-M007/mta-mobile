import 'package:dio/dio.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/AddAttendanceRes.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/AddDocRes.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/BackLinkRes.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/Chat/AddRemoveUserListRes.dart';
import 'package:mta/models/Chat/ChatMessageWithPageCountRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/models/Chat/GroupCreationRes.dart';
import 'package:mta/models/Chat/MediaDetailsRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/CurrentProjectReq.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/EditProfileReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/ForwardMessageReq.dart';
import 'package:mta/models/GroupDetailsRes.dart';
import 'package:mta/models/GroupReq.dart';
import 'package:mta/models/GroupRes.dart';
import 'package:mta/models/MeetingAccessRes.dart';
import 'package:mta/models/MeetingDetails.dart';
import 'package:mta/models/MeetingsDataRes.dart';
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
import 'package:mta/models/TeamUsersRes.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/models/UpdateMeetingReq.dart';
import 'package:mta/models/UserAccessreq.dart';
import 'package:mta/models/cancelMeetingReq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//
import 'package:retrofit/retrofit.dart';

import '../models/AccessDetailsRes.dart';
import '../models/Chat/GroupUsersRes.dart';
import '../models/FetchCategoryUsersRes.dart';
import '../models/LoginStatusRes.dart';
part 'ApiService.g.dart';

// Run this code in termial to generate ApiService.g.dart file
// flutter packages pub run build_runner watch --delete-conflicting-outputs

@RestApi(baseUrl: "https://demo.emeetify.com:81/mta")

// @RestApi(baseUrl: "https://mta.multitechcorp.in/mta")
// @RestApi(baseUrl: "http://192.168.0.112:5777/mta")

abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

//////////////////////////////////////////////////////////////////////////////////////////
  /// Login and Signup Module
//////////////////////////////////////////////////////////////////////////////////////////

  @POST("/users/login")
  Future<LoginRes> login(@Body() LoginReq body);

  @POST("/users/publicusersignup")
  Future<CommonRes> signUp(@Body() SignUpReq body);

  @PUT("/users/{user_id}")
  Future<LoginRes> setPin(@Path("user_id") int id, @Body() SetPinReq body);

  @POST("/users/changePin")
  Future<LoginRes> setForgotPin(
      @Path("user_id") int id, @Body() SetPinReq body);

  @POST("/projects/currentProject")
  Future<LoginRes> setCurrentProject(@Body() CurrentProjectReq body);

  @PUT("/projects/putCategory/{user_id}")
  Future<LoginRes> userAccess(
      @Path("user_id") String id, @Body() UserAccessReq body);

  @GET("/projects?user_id={user_id}")
  Future<DashboardRes> projects(@Path("user_id") int id);

  @GET("/newsfeed")
  Future<NewsRes> news();

  @GET("/users/profile/{user_id}")
  Future<ProfileRes> profile(@Path("user_id") int userId);

  @GET("/chat/getUsersByGroupId?group_id={group_id}")
  Future<GroupUsersRes> getChatUsers(@Path("group_id") int groupid);

  @GET("/users/getUserLoginHours?user_id={user_id}")
  Future<LoginStatusRes> fetchLoginHours(@Path("user_id") int userId);

  @GET(
      "/projects/getDocuments?category_id={category_id}&project_id={project_id}&users_id={users_id}")
  Future<FetchCategoryDocRes> getCategoryDoc(@Path("category_id") int id,
      @Path("project_id") int pid, @Path("users_id") int userid);

  @GET("/projects/getDocuments?project_id={project_id}&&users_id={users_id}")
  Future<FectchProjectDocRes> getProjectDoc(
      @Path("project_id") int id, @Path("users_id") int userid);

  @GET("/categories?project_id={project_id}&&type=mobile")
  Future<FectchCatsRes> getCats(@Path("project_id") int id);

  @GET("/chat/unlinkedUsersInGroup?group_id={id}")
  Future<AddUsersListRes> getUnlinkedUsers(@Path("id") int id);

  @POST("/projects/addDocument")
  Future<AddDocRes> addDoc(@Body() AddDocReq body);

  @POST("/attendance")
  Future<AddAttendanceRes> addAttendance(@Body() AddAttendanceReq body);

  @POST("/chat/addUsersIntoGroup")
  Future<AddAttendanceRes> addRemoveUsersintoGroup(
      @Body() AddRemoveUserReq body);

  @POST("/chat/removeUserInGroup")
  Future<AddAttendanceRes> removeUsersintoGroup(@Body() AddRemoveUserReq body);

  @GET("/attendance?user_id={user_id}&date={date}")
  Future<FetchAttendanceRes> getAttendance(
      @Path("user_id") int id, @Path("date") String date);

  @GET("/categories?project_id={project_id}")
  Future<FetchMapedCatRes> fetchCats(@Path("project_id") int id);

  @GET(
      "/categories/getCatUsers?project_id={project_id}&category_id={category_id}")
  Future<FetchCategoryUsersRes> getCatUsers(
      @Path("project_id") int id, @Path("category_id") int catid);

  @GET("/projects/getmappedUser?project_id={project_id}")
  Future<FetchMapedUsersRes> fetchUsers(@Path("project_id") int id);

  @GET("/chat/getMessageReadedUsers?message_id={message_id}")
  Future<FetchMapedUsersRes> getReadedUsers(@Path("message_id") int id);

  @GET("/teams")
  Future<TeamsModel> fetchTeams();

  @GET("/teams/getTeamUsers/{team_id}")
  Future<TeamUsersRes> fetchTeamUsers(@Path("team_id") int id);

  @GET("/projects/getProjectsByTeam/{team_id}")
  Future<DashboardRes> fetchProjectByTeams(@Path("team_id") int id);

  @GET("/projects/getProject/{project_id}")
  Future<ProjectDetailsRes> getProjectName(@Path("project_id") int id);

  @GET("/chat/getGroupFiles?group_id={group_id}&file_type={file_type}")
  Future<MediaDetailsRes> getMediaDetails(
      @Path("group_id") int id, @Path("file_type") String type);

  @GET("/utils/getNotification")
  Future<NotificationRes> notification();

  @GET("/chat/groupCreateAccessDetails")
  Future<AccessDetailsRes> getAccessDetails();

  @GET(
      "/chat/getureadMessageDetails?group_type={group_type}&team_id={team_id}&project_id={project_id}&user_id={user_id}&type={type}&group_id={group_id}")
  Future<ChatMessageWithPageCountRes> checkMessageAvailability(
      @Path("project_id") int? projectId,
      @Path("team_id") int? teamId,
      @Path("user_id") int? userId,
      @Path("group_type") String? groupType,
      @Path("type") String? type,
      @Path("group_id") int? grpId);

  @GET("/chat/getMessagesByGroupId?group_id={group_id}&page_no={page_no}")
  Future<ChatMessageWithPageCountRes> getMessagesWithPageCount(
      @Path("group_id") int id, @Path("page_no") int pageNo);

  @POST("/users/changePassword")
  Future<CommonRes> changePass(@Body() ChangePassReq body);

  @POST("/chat/createGroup")
  Future<GroupCreationRes> createGroup(@Body() GroupCreationReq body);

  @POST("/users/forgotPassword")
  Future<CommonRes> forgotPass(@Body() ForgotPassReq body);

  @POST("/users/validate_otp")
  Future<CommonRes> otpVerify(@Body() ValidateOTPReq body);

  @PUT("/users/{user_id}")
  Future<CommonRes> editProfile(
      @Path("user_id") int id, @Body() EditProfileReq body);

  @PUT("/utils/updateNotification/{noti_id}")
  Future<CommonRes> updateNotificationStatus(@Path("noti_id") int id);
  @PUT("/chat/updateFileDownloadStatus?message_id={msg_id}&status={status}")
  Future<CommonRes> updateDownloadStatus(
      @Path("msg_id") int id, @Path("status") int status);

  @DELETE("/users/removeImage/{user_id}")
  Future<CommonRes> removeProPic(@Path("user_id") int id);
  @DELETE("/chat/deleteMessage?message_id={msg_id}&&group_id={grp_id}")
  Future<CommonRes> deleteMessage(
      @Path("msg_id") int id, @Path("grp_id") int grpId);

  @DELETE("/users/{user_id}")
  Future<CommonRes> deleteUser(@Path("user_id") int id);

  @DELETE("/users/deleteDeviceId/{user_id}")
  Future<CommentsRes> removeDeviceId(@Path("user_id") int id);

  @DELETE("/utils/deletecomment/{comment_id}")
  Future<CommentsRes> removeComment(@Path("comment_id") int id);

  @POST("/utils/getAudioUrl")
  Future<AudioRes> uploadAudio(@Body() AudioReq body);

  @GET("/users/backlink")
  Future<BackLinkRes> getSocialsBackLink();

  @POST("/chat/getGroupDetails")
  Future<GroupRes> fetchGroupList(@Body() GroupReq body);

  @POST("/chat/forwardMessage")
  Future<AudioRes> sendForwadMessage(@Body() ForwadMessageReq body);

  @DELETE("/chat/deleteGroup?group_id={group_id}")
  Future<CommentsRes> deleteGroup(@Path("group_id") int id);

  @GET("/chat/getGroupDetailsByGroupId?group_id={group_id}")
  Future<GroupDetailsRes> getGroupData(@Path("group_id") int id);

  @GET(
      "/chat/getTeamProjectUsers?group_type={group_type}&team_id={team_id}&project_id={project_id}")
  Future<AddUsersListRes> getUsers(
    @Path("group_type") String? groupType,
    @Path("team_id") int? teamId,
    @Path("project_id") int? projectId,
  );

  @GET("/chat/checkGroupExists/{group_name}")
  Future<CommonRes> checkGroupName(@Path("group_name") String groupName);

  @GET("/meeting/getupcomingmeeting?dates={date}")
  Future<MeetingsDataRes> getUpcomingMeeting(@Path("date") String date);

  @GET("/meeting/getupcomingmeeting?date={date}")
  Future<MeetingsDataRes> getMeetingHistory(@Path("date") String date);

  @GET("/meeting/getmeeting/{meeting_id}")
  Future<MeetingDetailsRes> getMeetingById(@Path("meeting_id") int meeting_id);

  @GET("/meeting/accessdetails/{user_id}")
  Future<MeetingAccessRes> getMeetingAccess(@Path("user_id") int user_id);

  @GET("/meeting/allteams")
  Future<AllTeamsRes> fetchAllTeams();

  @GET("/meeting/allprojects")
  Future<DashboardRes> fetchAllProjects();

  @POST("/meeting/createmeeting")
  Future<CommonRes> createMeeting(@Body() AddMeetingReq body);

  @PUT("/meeting/updatemeeting")
  Future<CommonRes> updateMeeting(@Body() UpdateMeetingReq body);

  @DELETE("/meeting/deletemeeting")
  Future<CommonRes> deleteMeeting(@Body() CancelMeetingReq body);

/////////////////////////////////////////////////////////////////////////////////////////
  /// Request and Response Body
//////////////////////////////////////////////////////////////////////////////////////////

  static ApiService create() {
    final dio = Dio();
    try {
      print("trying dio");
      dio.interceptors.add(PrettyDioLogger());
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (options, handler) async {
        options.headers["Content-Type"] = "application/json";
        options.headers["x-access-token"] = Strings.authToken;
        //options.headers["Host"] = "<calculated when request is sent>";
        options.followRedirects = false;
        // options.data = (data){
        //   print("dataa $data");
        // };
        options.validateStatus = (status) {
          Strings.statusCode = status!;
          if (status == 401) {
            Strings.isLogin = false;
            AppUtils.showToastError(
                "Session has been expired ! Please login again");
            navigatorKey.currentState?.popAndPushNamed('/verifypin');
            // return false;
          } else if (status == 502) {
            AppUtils.showToastError("Bad Gateway");
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
