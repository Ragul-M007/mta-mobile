import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/ChatView/extensions/extensions.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../utilities/strings.dart';
import '../chatview.dart';

class ImageMessageView extends StatefulWidget {
  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
    required this.onSelectionTapped,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  final VoidCallBack onSelectionTapped;

  String get imageUrl => message.message;

  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  var dio = Dio();

  var downloadStatus;

  @override
  void initState() {
    super.initState();
    downloadStatus = widget.message.status;
  }

  downloadfile(
    serverURL,
    filename,
  ) async {
    // AppUtils.showprogress();
    // AppUtils.showToast('Downloading');

    print("serverURL--> ${jsonEncode(serverURL)}  file $filename");

    //var fileName = filename;//filenames[1];
    var extn = AppUtils.getFileExtension(serverURL);
    var nospace = filename.replaceAll(' ', '');
    var fileName = nospace + extn;
    print("url--> $fileName");
    var basePath = Strings.basePath;

    String fullPath = "$basePath/$fileName";
    print("filepath $fullPath");

    var downloadedFile = await download2(dio, serverURL, '$basePath/$fileName');
    // var downloadedFile = await downloadFile(serverURL, fileName, path!);
    // AppUtils.openFile(downloadedFile);
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      var myUrl = url;
      Response response = await dio.get(
        myUrl,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      var filePath;
      if (response.statusCode == 200) {
        AppUtils.dismissprogress();
        filePath = savePath;
        file = File(filePath);
        AppUtils.updateDownloadStatus(int.parse(widget.message.id), context);
        setState(() {
          downloadStatus = MessageStatus.downloaded;
        });
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
        filePath = 'Error code: ' + response.statusCode.toString();
      }
      return filePath;
    } catch (e) {
      AppUtils.dismissprogress();
      var filePath = 'Error $e';
      print(e);
      return filePath;
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      AppUtils.showprogresswithpercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.isMessageBySender
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        // if (widget.isMessageBySender) widget.iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                // check selection is enabled
                if (Strings.isSelectionEnabled) {
                  widget.onSelectionTapped.call();
                } else {
                  if (downloadStatus == MessageStatus.downloaded) {
                    var finalPath = Strings.basePath! +
                        "/" +
                        (widget.message.fileName ?? "") +
                        AppUtils.getFileExtension(widget.message.message);

                    var checkdt = await io.Directory(finalPath).exists();
                    var kkdk = io.Directory(finalPath).existsSync();

                    print("qwwwwe $checkdt   $kkdk");

                    OpenFilex.open(finalPath);
                  } else {
                    downloadfile(
                        widget.message.message, widget.message.fileName);
                  }
                }
              },
              child: Transform.scale(
                scale: widget.highlightImage ? widget.highlightScale : 1.0,
                alignment: widget.isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      widget.imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: widget.imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: widget.isMessageBySender ? 6 : 0,
                        left: widget.isMessageBySender ? 0 : 6,
                        bottom: widget.message.reaction.reactions.isNotEmpty
                            ? 15
                            : 0,
                      ),
                  height: widget.imageMessageConfig?.height ?? 200,
                  width: widget.imageMessageConfig?.width ?? 150,
                  child: ClipRRect(
                    borderRadius: widget.imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      if (widget.imageUrl.isUrl &&
                          (widget.imageUrl.toLowerCase().contains('.png') ||
                              widget.imageUrl.toLowerCase().contains('.jpeg') ||
                              widget.imageUrl.toLowerCase().contains('.jpg')) &&
                          downloadStatus != MessageStatus.downloaded) {
                        return Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 5),
                          child: Column(
                            children: [
                              Container(
                                height:
                                    (widget.imageMessageConfig?.height ?? 200) -
                                        40,
                                child: Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.fill,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 6, right: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    downloadStatus == MessageStatus.downloaded
                                        ? Container()
                                        : Icon(
                                            Icons.download,
                                            size: 20,
                                          ),
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(widget.message.createdAt),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      } else if (widget.imageUrl.isUrl &&
                          (widget.imageUrl.contains('.png') ||
                              widget.imageUrl.contains('.jpeg') ||
                              widget.imageUrl.contains('.jpg')) &&
                          downloadStatus == MessageStatus.downloaded) {
                        print("image mem");
                        var finalPath = Strings.basePath! +
                            "/" +
                            (widget.message.fileName ?? "") +
                            AppUtils.getFileExtension(widget.message.message);
                        return Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 5),
                          child: Column(
                            children: [
                              Container(
                                height:
                                    (widget.imageMessageConfig?.height ?? 200) -
                                        40,
                                child: Image.file(
                                  File(finalPath),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(left: 6, right: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      downloadStatus == MessageStatus.downloaded
                                          ? Container()
                                          : Icon(
                                              Icons.download,
                                              size: 20,
                                            ),
                                      Text(
                                        DateFormat('hh:mm a')
                                            .format(widget.message.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        );
                      } else {
                        print("image elseee");
                        return Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              left: 5, right: 15, top: 15, bottom: 5),
                          child: Column(
                            children: [
                              Image.asset(
                                AppUtils.getFileExt(widget.imageUrl),
                                fit: BoxFit.fill,
                              ),
                              Spacer(),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(left: 6, right: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      downloadStatus == MessageStatus.downloaded
                                          ? Container()
                                          : Icon(
                                              Icons.download,
                                              size: 20,
                                            ),
                                      Text(
                                        DateFormat('hh:mm a')
                                            .format(widget.message.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        );
                      }
                    }()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
