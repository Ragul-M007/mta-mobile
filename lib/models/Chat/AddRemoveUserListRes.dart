class AddUsersListRes {
  bool? status;
  String? message;
  List<AddUsersData>? data;

  AddUsersListRes({this.status, this.message, this.data});

  AddUsersListRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AddUsersData>[];
      json['data'].forEach((v) {
        data!.add(new AddUsersData.fromJson(v));
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

class AddUsersData {
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
  bool? alreadyLinked;
  bool? isSelected = false;

  AddUsersData(
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
      this.alreadyLinked,
      this.isSelected});

  AddUsersData.fromJson(Map<String, dynamic> json) 
  {
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
    alreadyLinked = json['alreadyLinked'];
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['user_mobile_no'] = this.userMobileNo;
    data['user_image'] = this.userImage;
    data['group_name'] = this.groupName;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    data['team_id'] = this.teamId;
    data['group_type'] = this.groupType;
    data['alreadyLinked'] = this.alreadyLinked;
    data['isSelected'] = false;
    return data;
  }
}
