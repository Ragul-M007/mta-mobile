class ChatNotificationRes {
  String? projectId;
  String? groupId;
  String? groupType;
  String? teamId;
  String? groupName;

  ChatNotificationRes(
      {this.projectId, this.groupId, this.groupType, this.teamId,this.groupName});

  ChatNotificationRes.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    groupId = json['group_id'];
    groupType = json['group_type'];
    teamId = json['team_id'];
    groupName = json['group_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_id'] = this.projectId;
    data['group_id'] = this.groupId;
    data['group_type'] = this.groupType;
    data['team_id'] = this.teamId;
    data['group_name'] = this.groupName;

    return data;
  }
}
