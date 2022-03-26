class AddDocReq {
  int? categoryId;
  String? description;
  //List<String> file;
  String? file;
  String? fileName;
  int? projectId;
  int? userId;

  AddDocReq(
      {this.categoryId,
      this.description,
      this.file,
      this.fileName,
      this.projectId,
      this.userId});

  AddDocReq.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    description = json['description'];
    file = json['file'].cast<String>();
    fileName = json['file_name'];
    projectId = json['project_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['description'] = this.description;
    data['file'] = this.file;
    data['file_name'] = this.fileName;
    data['project_id'] = this.projectId;
    data['user_id'] = this.userId;
    return data;
  }
}
