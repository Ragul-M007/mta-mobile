class AddMeetingReq {
  String? title;
  String? description;
  String? start;
  String? end;
  String? type;
  String? inviteeTimezone;
  String? provider;
  String? location;
  List<String>? guestEmail;
  String? meetingType;
  List<int>? meetingTypeId;

  AddMeetingReq(
      {this.title,
      this.description,
      this.start,
      this.end,
      this.type,
      this.inviteeTimezone,
      this.provider,
      this.location,
      this.guestEmail,
      this.meetingType,
      this.meetingTypeId});

  AddMeetingReq.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    start = json['start'];
    end = json['end'];
    type = json['type'];
    inviteeTimezone = json['invitee_timezone'];
    provider = json['provider'];
    location = json['location'];
    guestEmail = json['guests_email'].cast<String>();
    meetingType = json['meeting_type'];
    meetingTypeId = json['meeting_type_id'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['start'] = this.start;
    data['end'] = this.end;
    data['type'] = this.type;
    data['invitee_timezone'] = this.inviteeTimezone;
    data['provider'] = this.provider;
    data['location'] = this.location;
    data['guests_email'] = this.guestEmail;
    data['meeting_type'] = this.meetingType;
    data['meeting_type_id'] = this.meetingTypeId;
    return data;
  }
}
