class ForgotPassReq {
  String? emailId;

  ForgotPassReq({this.emailId});

  ForgotPassReq.fromJson(Map<String, dynamic> json) {
    emailId = json['email_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_id'] = this.emailId;
    return data;
  }
}
