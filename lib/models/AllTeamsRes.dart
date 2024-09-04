class AllTeamsRes {
  bool? status;
  String? message;
  List<AllTeamsData>? data;

  AllTeamsRes({this.status, this.message, this.data});

  AllTeamsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AllTeamsData>[];
      json['data'].forEach((v) {
        data!.add(new AllTeamsData.fromJson(v));
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

class AllTeamsData {
  int? teamId;
  String? teamName;
  String? description;
  String? createdBy;
  int? users;
  int? projects;
  String? unReadedUserId;

  AllTeamsData(
      {this.teamId,
      this.teamName,
      this.description,
      this.createdBy,
      this.users,
      this.projects,
      this.unReadedUserId});

  AllTeamsData.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    teamName = json['team_name'];
    description = json['description'];
    createdBy = json['created_by'];
    users = json['users'];
    projects = json['projects'];
    unReadedUserId = json['un_readed_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['team_name'] = this.teamName;
    data['description'] = this.description;
    data['created_by'] = this.createdBy;
    data['users'] = this.users;
    data['projects'] = this.projects;
    data['un_readed_user_id'] = this.unReadedUserId;
    return data;
  }
}
