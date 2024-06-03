

// Different types Message of ChatView
enum MessageType {
  image,
  text,

  /// Only supported on android and ios
  voice,
  custom
}

/// Events, Wheter the user is still typing a message or has
/// typed the message
enum TypeWriterStatus { typing, typed }

/// [MessageStatus] defines the current state of the message
/// if you are sender sending a message then, the
enum MessageStatus { read, delivered, undelivered, pending, downloaded, downloadPending }

/// Types of states
enum ChatViewState { hasMessages, noData, loading, error }

enum ShowReceiptsIn { all, lastMessage }

extension ChatViewStateExtension on ChatViewState {
  bool get hasMessages => this == ChatViewState.hasMessages;

  bool get isLoading => this == ChatViewState.loading;

  bool get isError => this == ChatViewState.error;

  bool get noMessages => this == ChatViewState.noData;
}
