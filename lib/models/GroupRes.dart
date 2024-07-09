class GroupRes {
  bool? status;
  String? message;
  List<Data>? data;

  GroupRes({this.status, this.message, this.data});

  GroupRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  int? groupMemberId;
  int? groupId;
  int? userId;
  String? groupMemberCreatedAt;
  String? groupMemberUpdatedAt;
  String? groupName;
  String? groupDescription;
  String? groupImage;
  String? groupType;
  int? projectId;
  int? groupCreatedBy;
  String? groupCreatedAt;
  String? groupUpdatedAt;
  int? teamId;

  Data(
      {this.groupMemberId,
      this.groupId,
      this.userId,
      this.groupMemberCreatedAt,
      this.groupMemberUpdatedAt,
      this.groupName,
      this.groupDescription,
      this.groupImage,
      this.groupType,
      this.projectId,
      this.groupCreatedBy,
      this.groupCreatedAt,
      this.groupUpdatedAt,
      this.teamId});

  Data.fromJson(Map<String, dynamic> json) {
    groupMemberId = json['group_member_id'];
    groupId = json['group_id'];
    userId = json['user_id'];
    groupMemberCreatedAt = json['group_member_created_at'];
    groupMemberUpdatedAt = json['group_member_updated_at'];
    groupName = json['group_name'];
    groupDescription = json['group_description'];
    groupImage = json['group_image'];
    groupType = json['group_type'];
    projectId = json['project_id'];
    groupCreatedBy = json['group_created_by'];
    groupCreatedAt = json['group_created_at'];
    groupUpdatedAt = json['group_updated_at'];
    teamId = json['team_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_member_id'] = this.groupMemberId;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['group_member_created_at'] = this.groupMemberCreatedAt;
    data['group_member_updated_at'] = this.groupMemberUpdatedAt;
    data['group_name'] = this.groupName;
    data['group_description'] = this.groupDescription;
    data['group_image'] = this.groupImage;
    data['group_type'] = this.groupType;
    data['project_id'] = this.projectId;
    data['group_created_by'] = this.groupCreatedBy;
    data['group_created_at'] = this.groupCreatedAt;
    data['group_updated_at'] = this.groupUpdatedAt;
    data['team_id'] = this.teamId;
    return data;
  }
}
