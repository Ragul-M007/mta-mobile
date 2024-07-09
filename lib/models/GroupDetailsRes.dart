class GroupDetailsRes {
  bool? status;
  String? message;
  Data? data;

  GroupDetailsRes({this.status, this.message, this.data});

  GroupDetailsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? groupId;
  String? groupName;
  String? groupDescription;
  Null? groupImage;
  String? groupType;
  Null? projectId;
  int? groupCreatedBy;
  String? createdAt;
  String? updatedAt;
  int? teamId;

  Data(
      {this.groupId,
      this.groupName,
      this.groupDescription,
      this.groupImage,
      this.groupType,
      this.projectId,
      this.groupCreatedBy,
      this.createdAt,
      this.updatedAt,
      this.teamId});

  Data.fromJson(Map<String, dynamic> json) {
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
