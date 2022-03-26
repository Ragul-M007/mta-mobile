class ChangePassReq {
  String? emailId;
  String? password;
  String? newPassword;

  ChangePassReq({this.emailId, this.password, this.newPassword});

  ChangePassReq.fromJson(Map<String, dynamic> json) {
    emailId = json['email_id'];
    password = json['password'];
    newPassword = json['newPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_id'] = this.emailId;
    data['password'] = this.password;
    data['newPassword'] = this.newPassword;
    return data;
  }
}
