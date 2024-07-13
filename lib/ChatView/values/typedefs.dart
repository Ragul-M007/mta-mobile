import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../chatview.dart';

typedef StringCallback = void Function(String);
typedef StringMessageCallBack = void Function(
    String message, ReplyMessage replyMessage, MessageType messageType);
typedef ReplyMessageWithReturnWidget = Widget Function(
    ReplyMessage? replyMessage);
typedef ReplyMessageCallBack = void Function(ReplyMessage replyMessage);
typedef VoidCallBack = void Function();
typedef DoubleCallBack = void Function(double, double);
typedef MessageCallBack = void Function(Message message);
typedef ForwardCallBack = void Function(List<Message>);
typedef VoidCallBackWithFuture = Future<void> Function();
typedef StringsCallBack = void Function(String emoji, String messageId);
typedef StringWithReturnWidget = Widget Function(String separator);
typedef DragUpdateDetailsCallback = void Function(DragUpdateDetails);
typedef ListCallBack = void Function(
    String emoji, ReplyMessage msg, MessageType type, List<MultipartFile> file);
typedef DataRefreshCallback = void Function();
