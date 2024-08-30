class UpdateMeetingReq {
  String? start;
  String? end;
  String? type;
  String? meetingId;
  String? meeting;

  UpdateMeetingReq(
      {this.start, this.end, this.type, this.meetingId, this.meeting});

  UpdateMeetingReq.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
    type = json['type'];
    meetingId = json['meeting_id'];
    meeting = json['meeting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start'] = this.start;
    data['end'] = this.end;
    data['type'] = this.type;
    data['meeting_id'] = this.meetingId;
    data['meeting'] = this.meeting;
    return data;
  }
}
