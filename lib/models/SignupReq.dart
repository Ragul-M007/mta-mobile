class SignUpReq {
  int? roleId;
  String? name;
  String? email;
  String? mobileNo;
  String? password;
  String? city;
  String? area;
  String? prof;
  String? state;
  String? status;
  String? dob;
  String? anniverDate;
  String? userImg;
  int? publicUser;

  SignUpReq(
      {this.roleId,
      this.name,
      this.email,
      this.mobileNo,
      this.password,
      this.city,
      this.area,
      this.prof,
      this.state,
      this.status,
      this.dob,
      this.anniverDate,
      this.userImg,
      this.publicUser});

  SignUpReq.fromJson(Map<String, dynamic> json) {
    roleId = json['role_id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    password = json['password'];
    city = json['city'];
    area = json['area'];
    prof = json['prof'];
    state = json['state'];
    status = json['status'];
    dob = json['dob'];
    anniverDate = json['anniver_date'];
    userImg = json['user_img'];
    publicUser = json['public_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role_id'] = this.roleId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['password'] = this.password;
    data['city'] = this.city;
    data['area'] = this.area;
    data['prof'] = this.prof;
    data['state'] = this.state;
    data['status'] = this.status;
    data['dob'] = this.dob;
    data['anniver_date'] = this.anniverDate;
    data['user_img'] = this.userImg;
    data['public_user'] = this.publicUser;
    return data;
  }
}
