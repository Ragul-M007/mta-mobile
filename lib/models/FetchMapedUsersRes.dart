class FetchMapedUsersRes {
  bool? status;
  String? message;
  List<FetchMapedUsersData>? data;

  FetchMapedUsersRes({this.status, this.message, this.data});

  FetchMapedUsersRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <FetchMapedUsersData>[];
      json['data'].forEach((v) {
        data!.add(new FetchMapedUsersData.fromJson(v));
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

class FetchMapedUsersData {
  int? userId;
  String? name;
  String? prof;
  String? userImg;
  String? mobileNo;
  String? email;
  int? roleId;
  String? vwRights;

  FetchMapedUsersData(
      {this.userId,
      this.name,
      this.prof,
      this.userImg,
      this.mobileNo,
      this.email,
      this.roleId,
      this.vwRights});

  FetchMapedUsersData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    prof = json['prof'];
    userImg = json['user_img'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    roleId = json['role_id'];
    vwRights = json['vw_rights'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['prof'] = this.prof;
    data['user_img'] = this.userImg;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['role_id'] = this.roleId;
    data['vw_rights'] = this.vwRights;
    return data;
  }
}
