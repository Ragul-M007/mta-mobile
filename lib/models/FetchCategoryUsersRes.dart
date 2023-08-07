class FetchCategoryUsersRes {
  bool? status;
  String? message;
  List<CategoryUsersData>? data;

  FetchCategoryUsersRes({this.status, this.message, this.data});

  FetchCategoryUsersRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CategoryUsersData>[];
      json['data'].forEach((v) {
        data!.add(new CategoryUsersData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryUsersData {
  int? userId;
  String? name;
  Null? userImg;
  String? mobileNo;
  String? email;
  int? categoryId;
  String? prof;

  CategoryUsersData(
      {this.userId,
      this.name,
      this.userImg,
      this.mobileNo,
      this.email,
      this.categoryId,
      this.prof});

  CategoryUsersData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    userImg = json['user_img'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    categoryId = json['category_id'];
    prof = json['prof'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['user_img'] = this.userImg;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['category_id'] = this.categoryId;
    data['prof'] = this.prof;
    return data;
  }
}
