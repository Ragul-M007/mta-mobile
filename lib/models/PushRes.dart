class PushRes {
  String? file;
  int? projectId;
  String? fileName;
  int? documentId;
  String? projectName;

  PushRes(
      {this.file,
      this.projectId,
      this.fileName,
      this.documentId,
      this.projectName});

  PushRes.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    projectId = json['project_id'];
    fileName = json['file_name'];
    documentId = json['document_id'];
    projectName = json['project_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file;
    data['project_id'] = this.projectId;
    data['file_name'] = this.fileName;
    data['document_id'] = this.documentId;
    data['project_name'] = this.projectName;
    return data;
  }
}

// class PushRes {
//   Notification notification;
//   PushData data;

//   PushRes({this.notification, this.data});

//   PushRes.fromJson(Map<String, dynamic> json) {
//     notification = json['notification'] != null
//         ? new Notification.fromJson(json['notification'])
//         : null;
//     data = json['data'] != null ? new PushData.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.notification != null) {
//       data['notification'] = this.notification.toJson();
//     }
//     if (this.data != null) {
//       data['data'] = this.data.toJson();
//     }
//     return data;
//   }
// }

// class Notification {
//   String title;
//   String body;

//   Notification({this.title, this.body});

//   Notification.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     body = json['body'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['title'] = this.title;
//     data['body'] = this.body;
//     return data;
//   }
// }

// class PushData {
//   List<DocDetails> docDetails;
//   String body;
//   String image;
//   String title;

//   PushData({this.docDetails, this.body, this.image, this.title});

//   PushData.fromJson(Map<String, dynamic> json) {
//     if (json['docDetails'] != null) {
//       docDetails = new List<DocDetails>();
//       json['docDetails'].forEach((v) {
//         docDetails.add(new DocDetails.fromJson(v));
//       });
//     }
//     body = json['body'];
//     image = json['image'];
//     title = json['title'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.docDetails != null) {
//       data['docDetails'] = this.docDetails.map((v) => v.toJson()).toList();
//     }
//     data['body'] = this.body;
//     data['image'] = this.image;
//     data['title'] = this.title;
//     return data;
//   }
// }

// class DocDetails {
//   String file;
//   int projectId;
//   String fileName;
//   int documentId;
//   String projectName;

//   DocDetails(
//       {this.file,
//       this.projectId,
//       this.fileName,
//       this.documentId,
//       this.projectName});

//   DocDetails.fromJson(Map<String, dynamic> json) {
//     file = json['file'];
//     projectId = json['project_id'];
//     fileName = json['file_name'];
//     documentId = json['document_id'];
//     projectName = json['project_name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['file'] = this.file;
//     data['project_id'] = this.projectId;
//     data['file_name'] = this.fileName;
//     data['document_id'] = this.documentId;
//     data['project_name'] = this.projectName;
//     return data;
//   }
// }
