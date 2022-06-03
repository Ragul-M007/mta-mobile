class AddDocRes {
  bool? status;
  String? message;
  List<Data>? data;

  AddDocRes({this.status, this.message, this.data});

  AddDocRes.fromJson(Map<String, dynamic> json) 
  {
    status = json['status'];
    message = json['Message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() 
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Message'] = this.message;
    if (this.data != null) 
    {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? documentId;

  Data({this.documentId});

  Data.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    return data;
  }
}
