class AddRemoveUserReq {
  int? groupId;
  List<int>? userId;

  AddRemoveUserReq({this.groupId, this.userId});

  AddRemoveUserReq.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    userId = json['user_id'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    return data;
  }
}
