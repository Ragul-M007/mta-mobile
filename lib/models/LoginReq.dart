class LoginReq {
  String email;
  String password;
  String loginpin;
  // String emailId;
  // String country;

  LoginReq({this.email, this.password, this.loginpin});

  LoginReq.fromJson(Map<String, dynamic> json) {
    email = json['email_id'];
    password = json['password'];
    loginpin = json['loginpin'];
    // emailId = json['email_id'];
    // country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_id'] = this.email;
    data['password'] = this.password;
    data['loginpin'] = this.loginpin;
    // data['email_id'] = this.emailId;
    // data['country'] = this.country;
    return data;
  }
}
