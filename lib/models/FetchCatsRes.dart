class FectchCatsRes {
  bool status;
  String message;
  List<FectchCatsData> data;

  FectchCatsRes({this.status, this.message, this.data});

  FectchCatsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FectchCatsData>();
      json['data'].forEach((v) {
        data.add(new FectchCatsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FectchCatsData {
  int categoryId;
  String categoryName;
  String description;
  int projectId;

  FectchCatsData(
      {this.categoryId, this.categoryName, this.description, this.projectId});

  FectchCatsData.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    description = json['description'];
    projectId = json['project_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['description'] = this.description;
    data['project_id'] = this.projectId;
    return data;
  }
}
