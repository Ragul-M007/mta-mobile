class MeetingDetailsRes {
  bool? status;
  String? message;
  MeetingDetail? data;

  MeetingDetailsRes({this.status, this.message, this.data});

  MeetingDetailsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? new MeetingDetail.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MeetingDetail {
  String? title;
  String? description;
  String? start;
  String? end;
  String? type;
  String? inviteeTimezone;
  String? provider;
  String? location;
  int? calenderId;
  String? inviteeMobile;
  String? inviteeFirstName;
  String? inviteeLastName;
  String? inviteeEmail;
  List<String>? guestEmail;
  int? meetingId;
  String? meetingLink;
  int? userId;
  String? imeetifyMeetingId;

  MeetingDetail(
      {this.title,
      this.description,
      this.start,
      this.end,
      this.type,
      this.inviteeTimezone,
      this.provider,
      this.location,
      this.calenderId,
      this.inviteeMobile,
      this.inviteeFirstName,
      this.inviteeLastName,
      this.inviteeEmail,
      this.guestEmail,
      this.meetingId,
      this.meetingLink,
      this.userId,
      this.imeetifyMeetingId});

  MeetingDetail.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    start = json['start'];
    end = json['end'];
    type = json['type'];
    inviteeTimezone = json['invitee_timezone'];
    provider = json['provider'];
    location = json['location'];
    calenderId = json['calender_id'];
    inviteeMobile = json['invitee_mobile'];
    inviteeFirstName = json['invitee_first_name'];
    inviteeLastName = json['invitee_last_name'];
    inviteeEmail = json['invitee_email'];
    guestEmail = json['guest_email'].cast<String>();
    meetingId = json['meeting_id'];
    meetingLink = json['meeting_link'];
    userId = json['user_id'];
    imeetifyMeetingId = json['imeetify_meeting_id'];
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
    data['calender_id'] = this.calenderId;
    data['invitee_mobile'] = this.inviteeMobile;
    data['invitee_first_name'] = this.inviteeFirstName;
    data['invitee_last_name'] = this.inviteeLastName;
    data['invitee_email'] = this.inviteeEmail;
    data['guest_email'] = this.guestEmail;
    data['meeting_id'] = this.meetingId;
    data['meeting_link'] = this.meetingLink;
    data['user_id'] = this.userId;
    data['imeetify_meeting_id'] = this.imeetifyMeetingId;
    return data;
  }
}
