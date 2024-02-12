class GroupUsersRes {
  bool? status;
  String? message;
  List<GroupChatUsersData>? data;

  GroupUsersRes({this.status, this.message, this.data});

  GroupUsersRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GroupChatUsersData>[];
      json['data'].forEach((v) {
        data!.add(new GroupChatUsersData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupChatUsersData {
  String? userName;
  String? userEmail;
  String? userMobileNo;
  String? userImage;
  String? groupName;
  int? groupId;
  int? userId;
  int? projectId;
  int? teamId;
  String? groupType;
  bool? isSelected;
  int? groupCreateAccess;

  GroupChatUsersData(
      {this.userName,
      this.userEmail,
      this.userMobileNo,
      this.userImage,
      this.groupName,
      this.groupId,
      this.userId,
      this.projectId,
      this.teamId,
      this.groupType,
      this.isSelected,
      this.groupCreateAccess});

  GroupChatUsersData.fromJson(Map<String, dynamic> json) {
    isSelected = json['is_selected'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userMobileNo = json['user_mobile_no'];
    userImage = json['user_image'];
    groupName = json['group_name'];
    groupId = json['group_id'];
    userId = json['user_id'];
    projectId = json['project_id'];
    teamId = json['team_id'];
    groupType = json['group_type'];
    groupCreateAccess = json['group_create_access'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_name'] = this.userName;
    data['is_selected'] = this.isSelected;
    data['user_email'] = this.userEmail;
    data['user_mobile_no'] = this.userMobileNo;
    data['user_image'] = this.userImage;
    data['group_name'] = this.groupName;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    data['team_id'] = this.teamId;
    data['group_type'] = this.groupType;
    data['group_create_access'] = this.groupCreateAccess;
    return data;
  }
}
