class TeamsModel {
  bool? status;
  String? message;
  List<TeamsData>? data;

  TeamsModel({this.status, this.message, this.data});

  TeamsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TeamsData>[];
      json['data'].forEach((v) {
        data!.add(new TeamsData.fromJson(v));
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

class TeamsData {
  int? teamId;
  String? teamName;
  String? description;
  int? totalUnReadMessageCount;
  String? unReadedUserId;

  TeamsData({this.teamId, this.teamName, this.description, this.unReadedUserId});

  TeamsData.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    teamName = json['team_name'];
    description = json['description'];
    totalUnReadMessageCount = json['totalUnReadMessageCount'];
    unReadedUserId = json['un_readed_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['team_name'] = this.teamName;
    data['description'] = this.description;
    data['totalUnReadMessageCount'] = this.totalUnReadMessageCount;
    data['un_readed_user_id'] = this.unReadedUserId;
    return data;
  }
}
