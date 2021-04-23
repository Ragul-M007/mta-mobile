class FetchProjectDocReq {
  int projectId;

  FetchProjectDocReq({this.projectId});

  FetchProjectDocReq.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_id'] = this.projectId;
    return data;
  }
}
