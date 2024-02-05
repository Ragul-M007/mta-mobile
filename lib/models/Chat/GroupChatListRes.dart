class GroupListRes {
  int? userId;
  List<GroupDetails>? groupDetails;

  GroupListRes({this.userId, this.groupDetails});

  GroupListRes.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    if (json['group_details'] != null) {
      groupDetails = <GroupDetails>[];
      json['group_details'].forEach((v) {
        groupDetails!.add(new GroupDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    if (this.groupDetails != null) {
      data['group_details'] =
          this.groupDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupDetails 
{
  int? groupId;
  String? groupName;
  String? groupDescription;
  String? groupImage;
  String? groupType;
  int? projectId;
  int? groupCreatedBy;
  String? createdAt;
  String? updatedAt;
  int? teamId;
  int? unreadMessageCount;

  GroupDetails(
      {this.groupId,
      this.groupName,
      this.groupDescription,
      this.groupImage,
      this.groupType,
      this.projectId,
      this.groupCreatedBy,
      this.createdAt,
      this.updatedAt,
      this.teamId,
      this.unreadMessageCount});

  GroupDetails.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    groupName = json['group_name'];
    groupDescription = json['group_description'];
    groupImage = json['group_image'];
    groupType = json['group_type'];
    projectId = json['project_id'];
    groupCreatedBy = json['group_created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    teamId = json['team_id'];
    unreadMessageCount = json['unread_message_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_id'] = this.groupId;
    data['group_name'] = this.groupName;
    data['group_description'] = this.groupDescription;
    data['group_image'] = this.groupImage;
    data['group_type'] = this.groupType;
    data['project_id'] = this.projectId;
    data['group_created_by'] = this.groupCreatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['team_id'] = this.teamId;
    data['unread_message_count'] = this.unreadMessageCount;
    return data;
  }
}

