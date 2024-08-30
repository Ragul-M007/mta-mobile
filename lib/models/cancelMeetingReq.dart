class CancelMeetingReq {
  String? meeting;
  String? type;

  CancelMeetingReq({this.meeting, this.type});

  CancelMeetingReq.fromJson(Map<String, dynamic> json) {
    meeting = json['meeting'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['meeting'] = this.meeting;
    data['type'] = this.type;
    return data;
  }
}
