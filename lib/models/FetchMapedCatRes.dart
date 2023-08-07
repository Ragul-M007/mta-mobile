class FetchMapedCatRes {
  bool? status;
  String? message;
  List<CatsData>? data;

  FetchMapedCatRes({this.status, this.message, this.data});

  FetchMapedCatRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CatsData>[];
      json['data'].forEach((v) {
        data?.add(new CatsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CatsData {
  int? categoryId;
  String? categoryName;
  String? description;
  int? projectId;
  int? userCount;
  int? documentCounts;

  CatsData(
      {this.categoryId, this.categoryName, this.description, this.projectId,this.userCount,this.documentCounts});

  CatsData.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    description = json['description'];
    projectId = json['project_id'];
    userCount = json['user_count'];
    documentCounts = json['document_counts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['description'] = this.description;
    data['project_id'] = this.projectId;
    data['document_counts'] = this.documentCounts;
    data['user_count'] = this.userCount;
    return data;
  }
}
