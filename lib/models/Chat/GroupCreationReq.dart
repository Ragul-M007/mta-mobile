class GroupCreationReq {
  String? groupName;
  String? groupDescription;
  int? groupCreatedBy;
  String? groupType;
  int? projectId;
  int? teamId;
  Null? groupImage;

  GroupCreationReq(
      {this.groupName,
      this.groupDescription,
      this.groupCreatedBy,
      this.groupType,
      this.projectId,
      this.teamId,
      this.groupImage});

  GroupCreationReq.fromJson(Map<String, dynamic> json) {
    groupName = json['group_name'];
    groupDescription = json['group_description'];
    groupCreatedBy = json['group_created_by'];
    groupType = json['group_type'];
    projectId = json['project_id'];
    teamId = json['team_id'];
    groupImage = json['group_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_name'] = this.groupName;
    data['group_description'] = this.groupDescription;
    data['group_created_by'] = this.groupCreatedBy;
    data['group_type'] = this.groupType;
    data['project_id'] = this.projectId;
    data['team_id'] = this.teamId;
    data['group_image'] = this.groupImage;
    return data;
  }
}
