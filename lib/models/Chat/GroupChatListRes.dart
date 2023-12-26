class GroupListRes {
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

  GroupListRes(
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

  GroupListRes.fromJson(Map<String, dynamic> json) {
    unreadMessageCount = json['unread_message_count'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unread_message_count'] = this.unreadMessageCount;
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
    return data;
  }
}
