class IntegratedMeetingsData {
  bool? status;
  String? message;
  List<IntegratedMeetings>? data;

  IntegratedMeetingsData({this.status, this.message, this.data});

  IntegratedMeetingsData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <IntegratedMeetings>[];
      json['data'].forEach((v) {
        data!.add(new IntegratedMeetings.fromJson(v));
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

class IntegratedMeetings {
  String? providerName;
  int? provider;
  int? userId;

  IntegratedMeetings({this.providerName, this.provider, this.userId});

  IntegratedMeetings.fromJson(Map<String, dynamic> json) {
    providerName = json['provider_name'];
    provider = json['provider'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['provider_name'] = this.providerName;
    data['provider'] = this.provider;
    data['user_id'] = this.userId;
    return data;
  }
}
