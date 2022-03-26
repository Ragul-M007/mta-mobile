class UserAccessReq {
  int? projectId;
  String? userId;
  int? document;

  UserAccessReq({this.projectId, this.userId, this.document});

  UserAccessReq.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    userId = json['user_id'];
    document = json['document'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_id'] = this.projectId;
    data['user_id'] = this.userId;
    data['document'] = this.document;
    return data;
  }
}