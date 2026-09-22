part of 'viewdoclist_bloc.dart';

abstract class ViewDocListEvent {
  const ViewDocListEvent();
}

/// Mark a notification read (mirrors `updateNotification()`); [notificationId]
/// is dynamic to match the original untyped parameter.
class ViewDocNotificationUpdate extends ViewDocListEvent {
  final dynamic notificationId;

  const ViewDocNotificationUpdate(this.notificationId);
}

/// Load the documents (mirrors `getDocs()` — branches on `Strings.category`).
class ViewDocsRequested extends ViewDocListEvent {
  const ViewDocsRequested();
}

/// Load users + categories then open comments (mirrors `getUserCats()`).
class ViewDocUserCatsRequested extends ViewDocListEvent {
  const ViewDocUserCatsRequested();
}
