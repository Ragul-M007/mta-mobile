class LoginRes {
  bool status;
  String message;
  LoginResData data;
  String token;

  LoginRes({this.status, this.message, this.data, this.token});

  LoginRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? new LoginResData.fromJson(json['data']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class LoginResData {
  String name;
  int userId;
  String emailId;
  String mobileNo;
  String userImg;
  String role;
  int roleId;

  LoginResData(
      {this.name,
      this.userId,
      this.emailId,
      this.mobileNo,
      this.userImg,
      this.role,
      this.roleId});

  LoginResData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    userId = json['user_id'];
    emailId = json['email_id'];
    mobileNo = json['mobile_no'];
    userImg = json['user_img'];
    role = json['role'];
    roleId = json['role_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['email_id'] = this.emailId;
    data['mobile_no'] = this.mobileNo;
    data['user_img'] = this.userImg;
    data['role'] = this.role;
    data['role_id'] = this.roleId;
    return data;
  }
}
