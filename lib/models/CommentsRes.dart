class CommentsRes {
  int? commentUserId;
  bool? status;
  int? commentId;
  int? parentCommentId;
  String? comment;
  String? audio;
  String? date;
  String? recipientId;
  String? recipient;
  String? categoryIdList;
  String? categoryList;
  String? name;
  String? userImg;
  List<Replies>? replies;

  CommentsRes(
      {this.commentUserId,
      this.status,
      this.commentId,
      this.parentCommentId,
      this.comment,
      this.audio,
      this.date,
      this.recipientId,
      this.recipient,
      this.categoryIdList,
      this.categoryList,
      this.name,
      this.userImg,
      this.replies});

  CommentsRes.fromJson(Map<String, dynamic> json) {
    commentUserId = json['comment_user_id'];
    status = json['status'];
    commentId = json['comment_id'];
    parentCommentId = json['parent_comment_id'];
    comment = json['comment'];
    audio = json['audio'];
    date = json['date'];
    recipientId = json['recipient_id'];
    recipient = json['recipient'];
    categoryIdList = json['category_id_list'];
    categoryList = json['category_list'];
    name = json['name'];
    userImg = json['user_img'];
    if (json['replies'] != null) {
      replies = <Replies>[];
      json['replies'].forEach((v) {
        replies?.add(new Replies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['comment_user_id'] = this.commentUserId;
    data['comment_id'] = this.commentId;
    data['parent_comment_id'] = this.parentCommentId;
    data['comment'] = this.comment;
    data['audio'] = this.audio;
    data['date'] = this.date;
    data['recipient_id'] = this.recipientId;
    data['recipient'] = this.recipient;
    data['category_id_list'] = this.categoryIdList;
    data['category_list'] = this.categoryList;
    data['name'] = this.name;
    data['user_img'] = this.userImg;
    if (this.replies != null) {
      data['replies'] = this.replies?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Replies {
  int? commentUserId;
  String? date;
  String? comment;
  String? audio;
  String? userImg;
  String? recipient;
  String? commentBy;
  int? commentId;
  String? recipientId;
  String? categoryList;
  String? categoryIdList;
  int? parentCommentId;

  Replies(
      {this.date,
      this.commentUserId,
      this.comment,
      this.audio,
      this.userImg,
      this.recipient,
      this.commentBy,
      this.commentId,
      this.recipientId,
      this.categoryList,
      this.categoryIdList,
      this.parentCommentId});

  Replies.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    commentUserId = json['comment_user_id'];
    comment = json['comment'];
    audio = json['audio'];
    userImg = json['user_img'];
    recipient = json['recipient'];
    commentBy = json['comment_by'];
    commentId = json['comment_id'];
    recipientId = json['recipient_id'];
    categoryList = json['category_list'];
    categoryIdList = json['category_id_list'];
    parentCommentId = json['parent_comment_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment_user_id'] = this.commentUserId;
    data['date'] = this.date;
    data['comment'] = this.comment;
    data['audio'] = this.audio;
    data['user_img'] = this.userImg;
    data['recipient'] = this.recipient;
    data['comment_by'] = this.commentBy;
    data['comment_id'] = this.commentId;
    data['recipient_id'] = this.recipientId;
    data['category_list'] = this.categoryList;
    data['category_id_list'] = this.categoryIdList;
    data['parent_comment_id'] = this.parentCommentId;
    return data;
  }
}

// class CommentsRes {
//   int commentId;
//   int parentCommentId;
//   String comment;
//   String date;
//   int recipientId;
//   String recipient;
//   String name;
//   String userImg;
//   List<Replies> replies;

//   CommentsRes(
//       {this.commentId,
//       this.parentCommentId,
//       this.comment,
//       this.date,
//       this.recipientId,
//       this.recipient,
//       this.name,
//       this.userImg,
//       this.replies});

//   CommentsRes.fromJson(Map<String, dynamic> json) {
//     commentId = json['comment_id'];
//     parentCommentId = json['parent_comment_id'];
//     comment = json['comment'];
//     date = json['date'];
//     recipientId = json['recipient_id'];
//     recipient = json['recipient'];
//     name = json['name'];
//     userImg = json['user_img'];
//     if (json['replies'] != null) {
//       replies = new List<Replies>();
//       json['replies'].forEach((v) {
//         replies.add(new Replies.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['comment_id'] = this.commentId;
//     data['parent_comment_id'] = this.parentCommentId;
//     data['comment'] = this.comment;
//     data['date'] = this.date;
//     data['recipient_id'] = this.recipientId;
//     data['recipient'] = this.recipient;
//     data['name'] = this.name;
//     data['user_img'] = this.userImg;
//     if (this.replies != null) {
//       data['replies'] = this.replies.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Replies {
//   String date;
//   String comment;
//   String userImg;
//   String recipient;
//   String commentBy;
//   int commentId;
//   int recipientId;
//   int parentCommentId;

//   Replies(
//       {this.date,
//       this.comment,
//       this.userImg,
//       this.recipient,
//       this.commentBy,
//       this.commentId,
//       this.recipientId,
//       this.parentCommentId});

//   Replies.fromJson(Map<String, dynamic> json) {
//     date = json['date'];
//     comment = json['comment'];
//     userImg = json['user_img'];
//     recipient = json['recipient'];
//     commentBy = json['comment_by'];
//     commentId = json['comment_id'];
//     recipientId = json['recipient_id'];
//     parentCommentId = json['parent_comment_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['date'] = this.date;
//     data['comment'] = this.comment;
//     data['user_img'] = this.userImg;
//     data['recipient'] = this.recipient;
//     data['comment_by'] = this.commentBy;
//     data['comment_id'] = this.commentId;
//     data['recipient_id'] = this.recipientId;
//     data['parent_comment_id'] = this.parentCommentId;
//     return data;
//   }
// }
