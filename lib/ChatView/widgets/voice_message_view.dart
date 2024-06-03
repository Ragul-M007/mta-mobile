import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/apputilities.dart';
import '../../../../utilities/strings.dart';
import '../chatview.dart';
import '../models/voice_message_configuration.dart';

class VoiceMessageView extends StatefulWidget 
{
  const VoiceMessageView({
    Key? key,
    required this.screenWidth,
    required this.message,
    required this.fileName,
    required this.isMessageBySender,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.onMaxDuration,
    this.messageReactionConfig,
    this.config,
    this.downloadAudioRequest,
    this.parentDownloadStatus
  }) : super(key: key);

  /// Provides configuration related to voice message.
  final VoiceMessageConfiguration? config;

  /// Allow user to set width of chat bubble.
  final double screenWidth;

  /// Provides message instance of chat.
  final Message message;
  final Function(int)? onMaxDuration;
  final Function()? downloadAudioRequest;


  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  final String? fileName;

  final MessageStatus? parentDownloadStatus;


  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  final ValueNotifier<PlayerState> _playerState =
      ValueNotifier(PlayerState.stopped);

  PlayerState get playerState => _playerState.value;

  PlayerWaveStyle playerWaveStyle = const PlayerWaveStyle(scaleFactor: 70);

  var dio = Dio();

  var downloadStatus;
  var finalPath;



  @override
  void initState() 
  {
    super.initState();

     finalPath =   Strings.basePath! + "/"+ (widget.message.fileName ?? "") +
                                            AppUtils.getFileExtension(
                                                widget.message.message);
        print("message view33 ${widget.parentDownloadStatus}");
        downloadStatus = widget.parentDownloadStatus;

        if(downloadStatus == MessageStatus.downloaded)
        {
          controller = PlayerController()
                ..preparePlayer(
                  path: finalPath,
                  noOfSamples: widget.config?.playerWaveStyle
                          ?.getSamplesForWidth(widget.screenWidth * 0.5) ??
                      playerWaveStyle.getSamplesForWidth(widget.screenWidth * 0.5),
                ).whenComplete(() => widget.onMaxDuration?.call(controller.maxDuration));
              playerStateSubscription = controller.onPlayerStateChanged
                  .listen((state) => _playerState.value = state);

        }
        else
        {
          controller = PlayerController()
                ..preparePlayer(
                  path: '',
                  noOfSamples: widget.config?.playerWaveStyle
                          ?.getSamplesForWidth(widget.screenWidth * 0.5) ??
                      playerWaveStyle.getSamplesForWidth(widget.screenWidth * 0.5),
                ).whenComplete(() => widget.onMaxDuration?.call(controller.maxDuration));
              playerStateSubscription = controller.onPlayerStateChanged
                  .listen((state) => _playerState.value = state);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) 
        {
          print("qqwweerr");
  // executes after build
        });

     
  }



   

  

  initializePlayer(filePath)
  {
    setState(() {
      controller = PlayerController()
      ..preparePlayer(
        path: filePath,
        noOfSamples: widget.config?.playerWaveStyle
                ?.getSamplesForWidth(widget.screenWidth * 0.5) ??
            playerWaveStyle.getSamplesForWidth(widget.screenWidth * 0.5),
      ).whenComplete(() => widget.onMaxDuration?.call(controller.maxDuration));
    playerStateSubscription = controller.onPlayerStateChanged
        .listen((state) => _playerState.value = state);
    });

    setState(() {
      
    });
  }

  downloadfile(serverURL, filename,) async 
  {
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
  
  setState(() {
       initializePlayer(downloadedFile);
  });
 // initState();
    // var downloadedFile = await downloadFile(serverURL, fileName, path!);
    //AppUtils.openFile(downloadedFile);
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
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    _playerState.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    print("message view22 $downloadStatus  ${widget.parentDownloadStatus}");
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: widget.config?.decoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:       
        
                
                widget.isMessageBySender
                    ? widget.outgoingChatBubbleConfig?.color
                    : widget.inComingChatBubbleConfig?.color,
              ),
          padding: widget.config?.padding ??
              const EdgeInsets.symmetric(horizontal: 8),
          margin: widget.config?.margin ??
              EdgeInsets.symmetric(
                horizontal: 8,
                vertical: widget.message.reaction.reactions.isNotEmpty ? 15 : 0,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.parentDownloadStatus == MessageStatus.downloaded?
                  ValueListenableBuilder<PlayerState>(
                    builder: (context, state, child) {
                      return IconButton(
                        onPressed: _playOrPause,
                      // onPressed: downloadfile(widget.message,widget.fileName),
                        icon:
                            state.isStopped || state.isPaused || state.isInitialised
                                ? widget.config?.playIcon ??
                                     Icon(
                                      Icons.play_arrow,
                                      color: widget.isMessageBySender? Colors.white:Colors.black,
                                    )
                                : widget.config?.pauseIcon ??
                                     Icon(
                                      Icons.stop,
                                      color: widget.isMessageBySender? Colors.white:Colors.black,
                                    ),
                      );
                    },
                    valueListenable: _playerState,
                  ):
                  IconButton( onPressed: ()
                  {
                    widget.downloadAudioRequest!();
                    // downloadfile(widget.message.message,widget.message.fileName);
                  }, icon: Icon(Icons.download,
                  color: widget.isMessageBySender?Colors.white:Colors.black,)),
                  AudioFileWaveforms(
                    
                    size: Size(widget.screenWidth * 0.50, 60),
                    playerController: controller,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle:
                    PlayerWaveStyle(scaleFactor: 70,liveWaveColor: widget.isMessageBySender?Colors.white:Colors.black,fixedWaveColor: widget.isMessageBySender?Colors.white70:Colors.grey),
                      //  widget.config?.playerWaveStyle ?? playerWaveStyle,
                    padding: widget.config?.waveformPadding ??
                        const EdgeInsets.only(right: 10),
                    margin: widget.config?.waveformMargin,
                    animationCurve: Curves.easeIn,
                    
                    animationDuration: 
                        const Duration(milliseconds: 10),
                    enableSeekGesture: widget.config?.enableSeekGesture ?? true,
                  ),
                ],
              ),
              widget.isMessageBySender?
                      Text(DateFormat('hh:mm a').format(widget.message.createdAt),style: TextStyle(color:  Color.fromARGB(255, 246, 242, 242),fontSize: 12)):                           
                       Text(DateFormat('hh:mm a').format(widget.message.createdAt),style: TextStyle(color:Colors.black,fontSize: 12),),
              SizedBox(height: 3,)
            ],
          ),
        ),
        
      ],
    );
  }

  void _playOrPause() {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (playerState.isInitialised ||
        playerState.isPaused ||
        playerState.isStopped) {
      controller.startPlayer(finishMode: FinishMode.pause);
    } else {
      controller.pausePlayer();
    }
  }
}
