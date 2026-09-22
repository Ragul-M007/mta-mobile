part of 'adddoc_comments_bloc.dart';

abstract class AddDocCommentsEvent {
  const AddDocCommentsEvent();
}

/// Submit the media comment (mirrors the uploadAudio call in `submit()`);
/// [req] built by the widget.
class AddDocCommentsSubmitted extends AddDocCommentsEvent {
  final AudioReq req;

  const AddDocCommentsSubmitted(this.req);
}
