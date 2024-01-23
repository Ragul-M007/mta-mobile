
import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mta/screens/chat/ExampleChat.dart';

import '../../../../screens/MentionFiles/flutter_mentions.dart';
import '../../chatview.dart';
import '../utils/constants/constants.dart';
import '../utils/debounce.dart';
import '../utils/package_strings.dart';

class ChatUITextField extends StatefulWidget {
  const ChatUITextField({
   required this.textEditingKey,
    this.sendMessageConfig,
    required this.focusNode,
    required this.textEditingController,
    required this.onPressed,
    required this.onRecordingComplete,
    required this.onImageSelected,
  });

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration? sendMessageConfig;


  /// Provides focusNode for focusing text field.
  final FocusNode focusNode;

  /// Provides functions which handles text field.
  final TextEditingController textEditingController;

  final GlobalKey<FlutterMentionsState>? textEditingKey ;


  /// Provides callback when user tap on text field.
  final VoidCallBack onPressed;

  /// Provides callback once voice is recorded.
  final Function(String?) onRecordingComplete;

  /// Provides callback when user select images from camera/gallery.
  final StringsCallBack onImageSelected;

  

  @override
  State<ChatUITextField> createState() => _ChatUITextFieldState();
}

class _ChatUITextFieldState extends State<ChatUITextField> {
  final ValueNotifier<String> _inputText = ValueNotifier('');

  final ImagePicker _imagePicker = ImagePicker();

  RecorderController? controller;

  ValueNotifier<bool> isRecording = ValueNotifier(false);

  SendMessageConfiguration? get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration? get voiceRecordingConfig =>
      widget.sendMessageConfig?.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig?.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig?.textFieldConfig;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
      );

  ValueNotifier<TypeWriterStatus> composingStatus =
      ValueNotifier(TypeWriterStatus.typed);
        List<Map<String, dynamic>> userList = [];


  late Debouncer debouncer;

    final _fakeUsersDataServer = List.generate(100, (index) => "user$index");
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();


  @override
  void initState() {
    attachListeners();
    addMentionUsers();
    debouncer = Debouncer(
        sendMessageConfig?.textFieldConfig?.compositionThresholdTime ??
            const Duration(seconds: 1));
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      controller = RecorderController();
    }
  }

  addMentionUsers() {
    userList.clear();
    for (int i = 0; i < 10; i++) {
      var user = {
        "id": "56",
        "display": "raaam",
        "full_name": "raam",
        "photo": ""
      };
      setState(() {
              userList.add(user);
      });
    }
  }

  @override
  void dispose() {
    debouncer.dispose();
    composingStatus.dispose();
    isRecording.dispose();
    _inputText.dispose();
    super.dispose();
  }

  void attachListeners() {
    composingStatus.addListener(() {
      widget.sendMessageConfig?.textFieldConfig?.onMessageTyping
          ?.call(composingStatus.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            textFieldConfig?.padding ?? const EdgeInsets.symmetric(horizontal: 6),
        margin: textFieldConfig?.margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: textFieldConfig?.borderRadius ??
              BorderRadius.circular(textFieldBorderRadius),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isRecording,
          builder: (_, isRecordingValue, child) {
            return Row(
              children: [
                if (isRecordingValue && controller != null && !kIsWeb)
                  AudioWaveforms(
                    size: Size(MediaQuery.of(context).size.width * 0.75, 50),
                    recorderController: controller!,
                    margin: voiceRecordingConfig?.margin,
                    padding: voiceRecordingConfig?.padding ??
                        const EdgeInsets.symmetric(horizontal: 8),
                    decoration: voiceRecordingConfig?.decoration ??
                        BoxDecoration(
                          color: voiceRecordingConfig?.backgroundColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                    waveStyle: voiceRecordingConfig?.waveStyle ??
                        WaveStyle(
                          extendWaveform: true,
                          showMiddleLine: false,
                          waveColor: voiceRecordingConfig?.waveStyle?.waveColor ??
                              Colors.black,
                        ),
                  )
                else
                  Expanded(
                    child: 
                    Container(
                      child: FlutterMentions(
                          onChanged: (value){
                            _onChanged(value);
                            if (value.length > 0) {
                                    setState(() {
                                     // typing = true;
                                    });
                                  } else {
                                    setState(() {
                                      //typing = false;
                                    });
                                  }
                          },
                          key: widget.textEditingKey,
                          suggestionPosition: SuggestionPosition.Top,
                         
                          focusNode: widget.focusNode,
                       // controller: widget.textEditingController,
                        style: textFieldConfig?.textStyle ??
                            const TextStyle(color: Colors.white),
                        maxLines: textFieldConfig?.maxLines ?? 5,
                        minLines: textFieldConfig?.minLines ?? 1,
                        keyboardType: textFieldConfig?.textInputType,
                        textCapitalization: textFieldConfig?.textCapitalization ??
                            TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                              textFieldConfig?.hintText ?? PackageStrings.message,
                          fillColor: sendMessageConfig?.textFieldBackgroundColor ??
                              Colors.white,
                          filled: true,
                          hintStyle: textFieldConfig?.hintStyle ??
                              TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.25,
                              ),
                          contentPadding: textFieldConfig?.contentPadding ??
                              const EdgeInsets.symmetric(horizontal: 6),
                          border: _outLineBorder,
                          focusedBorder: _outLineBorder,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: textFieldConfig?.borderRadius ??
                                BorderRadius.circular(textFieldBorderRadius),
                          ),
                        ),
                          onMarkupChanged: (kll) {
                            print("mark changeddd $kll");
                          },
                          mentions: [
                            Mention(
                                trigger: '@',
                                style: TextStyle(
                                  color: Colors.amber,
                                ),
                                data: userList,
                                matchAll: false,
                                suggestionBuilder: (data) {
                                  return Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            data['photo'],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Text(data['full_name']),
                                            Text('@${data['display']}'),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                    ),
                  ),
                ValueListenableBuilder<String>(
                  valueListenable: _inputText,
                  builder: (_, inputTextValue, child) {
                    if (inputTextValue.isNotEmpty) {
                      return IconButton(
                        color: sendMessageConfig?.defaultSendButtonColor ??
                            Colors.green,
                        onPressed: () {
                          widget.onPressed();
                          _inputText.value = '';
                        },
                        icon: sendMessageConfig?.sendButtonIcon ??
                            const Icon(Icons.send),
                      );
                    } else {
                      return Row(
                        children: [
                          if (!isRecordingValue) ...[
                            
                             
                            if (sendMessageConfig?.enableGalleryImagePicker ??
                                true)
                              IconButton(
                                constraints: const BoxConstraints(),
                                onPressed: () => _onIconPressed(
                                  ImageSource.gallery,
                                  config:
                                      sendMessageConfig?.imagePickerConfiguration,
                                ),
                                icon: imagePickerIconsConfig
                                        ?.galleryImagePickerIcon ??
                                    Icon(
                                      Icons.attach_file,
                                      color: imagePickerIconsConfig
                                          ?.galleryIconColor,
                                    ),
                              ),
                          ],
                          if (sendMessageConfig?.allowRecordingVoice ??
                              true &&
                                  Platform.isIOS &&
                                  Platform.isAndroid &&
                                  !kIsWeb)
                            IconButton(
                              onPressed: _recordOrStop,
                              icon: (isRecordingValue
                                      ? voiceRecordingConfig?.micIcon
                                      : voiceRecordingConfig?.stopIcon) ??
                                  Icon(isRecordingValue ? Icons.stop : Icons.mic),
                              color: voiceRecordingConfig?.recorderIconColor,
                            )
                        ],
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      
    );
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (!isRecording.value) {
      await controller?.record();
      isRecording.value = true;
    } else {
      final path = await controller?.stop();
      isRecording.value = false;
      widget.onRecordingComplete(path);
    }
  }

  void _onIconPressed(
    ImageSource imageSource, {
    ImagePickerConfiguration? config,
  }) async {

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: imageSource,
        maxHeight: config?.maxHeight,
        maxWidth: config?.maxWidth,
        imageQuality: config?.imageQuality,
        preferredCameraDevice:
            config?.preferredCameraDevice ?? CameraDevice.rear,
      );
      String? imagePath = image?.path;
      if (config?.onImagePicked != null) {
        String? updatedImagePath = await config?.onImagePicked!(imagePath);
        if (updatedImagePath != null) imagePath = updatedImagePath;
      }
      widget.onImageSelected(imagePath ?? '', '');
    } catch (e) {
      widget.onImageSelected('', e.toString());
    }
  }

  void _onChanged(String inputText) {
    debouncer.run(() {
      composingStatus.value = TypeWriterStatus.typed;
    }, () {
      composingStatus.value = TypeWriterStatus.typing;
    });
    _inputText.value = inputText;
  }
}
