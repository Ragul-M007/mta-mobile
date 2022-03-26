class ValidateOTPReq {
  String? emailId;
  String? otp;

  ValidateOTPReq({this.emailId, this.otp});

  ValidateOTPReq.fromJson(Map<String, dynamic> json) {
    emailId = json['email_id'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_id'] = this.emailId;
    data['otp'] = this.otp;
    return data;
  }
}
