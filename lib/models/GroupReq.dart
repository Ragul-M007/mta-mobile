class GroupReq {
  String? userId;
  String? projectId;
  String? teamId;
  String? groupType;
  String? groupId;

  GroupReq(
      {this.userId, this.projectId, this.teamId, this.groupType, this.groupId});

  GroupReq.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    projectId = json['project_id'];
    teamId = json['team_id'];
    groupType = json['group_type'];
    groupId = json['group_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    data['team_id'] = this.teamId;
    data['group_type'] = this.groupType;
    data['group_id'] = this.groupId;
    return data;
  }
}
