class CurrentProjectReq {
  int? userId;
  int? projectId;

  CurrentProjectReq({this.userId, this.projectId});

  CurrentProjectReq.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    projectId = json['project_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    return data;
  }
}
