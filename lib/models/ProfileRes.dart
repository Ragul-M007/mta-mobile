class ProfileRes {
  String name;
  int userId;
  String emailId;
  String mobileNo;
  String userImg;
  String role;
  String city;
  String area;
  String state;
  int iat;
  int exp;
  String iss;

  ProfileRes(
      {this.name,
      this.userId,
      this.emailId,
      this.mobileNo,
      this.userImg,
      this.role,
      this.city,
      this.area,
      this.state,
      this.iat,
      this.exp,
      this.iss});

  ProfileRes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    userId = json['user_id'];
    emailId = json['email_id'];
    mobileNo = json['mobile_no'];
    userImg = json['user_img'];
    role = json['role'];
    iat = json['iat'];
    exp = json['exp'];
    iss = json['iss'];
    city = json['city'];
    area = json['area'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['email_id'] = this.emailId;
    data['mobile_no'] = this.mobileNo;
    data['user_img'] = this.userImg;
    data['role'] = this.role;
    data['iat'] = this.iat;
    data['exp'] = this.exp;
    data['iss'] = this.iss;
    data['city'] = this.city;
    data['area'] = this.area;
    data['state'] = this.state;
    return data;
  }
}
