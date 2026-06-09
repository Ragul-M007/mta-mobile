import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/external_path_helper.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class DocumentDownloadService {
  Future<String> buildExpectedLocalPath(String displayName, String extension) async {
    final Directory baseDir = await resolveDefaultDownloadsDirectory();
    final String safeName = sanitizeFileName(displayName);
    final String normalizedExt = extension.startsWith('.')
        ? extension.toLowerCase()
        : '.${extension.toLowerCase()}';
    return '${baseDir.path}/$safeName$normalizedExt';
  }

  Future<Directory> resolveDefaultDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final String path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
      final Directory androidDownloads = Directory(path);
      if (!await androidDownloads.exists()) {
        await androidDownloads.create(recursive: true);
      }
      return androidDownloads;
    }

    if (Platform.isIOS) {
      final Directory documents = await getApplicationDocumentsDirectory();
      if (!await documents.exists()) {
        await documents.create(recursive: true);
      }
      return documents;
    }

    final Directory? platformDownloads = await getDownloadsDirectory();
    if (platformDownloads != null) {
      if (!await platformDownloads.exists()) {
        await platformDownloads.create(recursive: true);
      }
      return platformDownloads;
    }

    final Directory root = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${root.path}/Downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> getCachedPathIfExists(String expectedPath) async {
    final File expectedFile = File(expectedPath);
    if (await expectedFile.exists() && await expectedFile.length() > 0) {
      return expectedPath;
    }

    final String expectedName = expectedFile.uri.pathSegments.isNotEmpty
        ? expectedFile.uri.pathSegments.last
        : '';
    final int dotIndex = expectedName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return null;
    }

    final String baseName = expectedName.substring(0, dotIndex);
    final Directory dir = expectedFile.parent;
    if (!await dir.exists()) {
      return null;
    }

    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is! File) {
        continue;
      }
      final String name = entity.uri.pathSegments.last;
      if (name.startsWith('$baseName.') && await entity.length() > 0) {
        return entity.path;
      }
    }

    return null;
  }

  Future<String?> downloadAndCacheFile({
    required Dio dio,
    required String downloadUrl,
    required String urlPath,
    required String displayName,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    String tempPath = '$savePath.part';

    try {
      debugPrint('DocumentDownloadService: download start -> $downloadUrl');
      AppUtils.showprogress();

      final Response<dynamic> response = await dio.get<dynamic>(
        downloadUrl,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (int? status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 404) {
        debugPrint('DocumentDownloadService: download failure 404 -> $downloadUrl');
        AppUtils.showToastError('Sorry, File  not Found !');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint(
          'DocumentDownloadService: download failure status=${response.statusCode} -> $downloadUrl',
        );
        AppUtils.showToastError(
          'Unable to download file. Error code: ${response.statusCode}',
        );
        return null;
      }

      final dynamic data = response.data;
      final List<int> bytes = data is Uint8List
          ? data
          : data is List<int>
              ? data
              : <int>[];

      if (bytes.isEmpty) {
        debugPrint('DocumentDownloadService: download failure empty bytes -> $downloadUrl');
        AppUtils.showToastError('Downloaded file is empty');
        return null;
      }

      final String finalExtension = resolvePreferredExtension(
        urlPath: urlPath,
        displayName: displayName,
        contentType: response.headers.value(Headers.contentTypeHeader),
        bytes: bytes,
      );

      final String expectedWithResolvedExt =
          await buildExpectedLocalPath(displayName, finalExtension);
      if (savePath != expectedWithResolvedExt) {
        savePath = expectedWithResolvedExt;
        tempPath = '$savePath.part';
      }

      final File tempFile = File(tempPath);
      if (!await tempFile.parent.exists()) {
        await tempFile.parent.create(recursive: true);
      }

      await tempFile.writeAsBytes(bytes, flush: true);

      if (!await tempFile.exists()) {
        debugPrint('DocumentDownloadService: download failure temp file missing -> $tempPath');
        AppUtils.showToastError('Unable to write downloaded file');
        return null;
      }

      final int writtenBytes = await tempFile.length();
      if (writtenBytes != bytes.length || writtenBytes == 0) {
        await _tryDelete(tempFile);
        debugPrint(
          'DocumentDownloadService: download failure byte mismatch expected=${bytes.length}, actual=$writtenBytes -> $downloadUrl',
        );
        AppUtils.showToastError('Download incomplete. Please try again.');
        return null;
      }

      final File finalFile = File(savePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(savePath);

      if (!await finalFile.exists() || await finalFile.length() == 0) {
        debugPrint('DocumentDownloadService: download failure final file invalid -> $savePath');
        AppUtils.showToastError('Unable to save downloaded file');
        return null;
      }

      debugPrint('DocumentDownloadService: download success -> $savePath');
      return savePath;
    } catch (e) {
      debugPrint('DocumentDownloadService: download failure exception -> $e');
      AppUtils.showToastError('Unable to download file');
      await _tryDelete(File(tempPath));
      return null;
    } finally {
      AppUtils.dismissprogress();
    }
  }

  Future<void> openFile(String filePath, {BuildContext? context}) async {
    try {
      if (filePath.isEmpty) {
        debugPrint('DocumentDownloadService: file open failure -> invalid path');
        AppUtils.showToastError('Invalid file path');
        return;
      }

      final File file = File(filePath);
      final String extension = extractExtension(file.path);
      if (extension.isEmpty) {
        debugPrint('DocumentDownloadService: file open failure -> missing extension for $filePath');
        AppUtils.showToastError('Unable to determine file type');
        return;
      }

      if (!await file.exists()) {
        debugPrint('DocumentDownloadService: file open failure -> file not found $filePath');
        AppUtils.showToastError('File not found');
        return;
      }

      final int bytes = await file.length();
      if (bytes <= 0) {
        debugPrint('DocumentDownloadService: file open failure -> empty file $filePath');
        AppUtils.showToastError('Downloaded file is empty');
        return;
      }

      final String mimeType = mimeTypeForExtension(extension);
      if (mimeType.isEmpty) {
        debugPrint('DocumentDownloadService: file open failure -> invalid mime type $extension');
        AppUtils.showToastError('Unsupported file type');
        return;
      }

      final OpenResult result = await OpenFilex.open(filePath, type: mimeType);

      if (result.type == ResultType.done) {
        debugPrint('DocumentDownloadService: file open success -> $filePath');
        return;
      }

      debugPrint(
        'DocumentDownloadService: file open failure type=${result.type}, message=${result.message}, file=$filePath',
      );

      if (result.type == ResultType.noAppToOpen) {
        AppUtils.showToastError('No application available to open this file');
        return;
      }
      if (result.type == ResultType.fileNotFound) {
        AppUtils.showToastError('File not found');
        return;
      }
      if (result.type == ResultType.permissionDenied) {
        debugPrint('DocumentDownloadService: file open permission denied -> $filePath');
        if (context != null && context.mounted) {
          await _showPermissionDeniedDialog(context);
        } else {
          AppUtils.showToastError('Permission denied while opening file');
        }
        return;
      }
      if (result.type == ResultType.error) {
        AppUtils.showToastError(
          result.message.isNotEmpty ? result.message : 'Unable to open file',
        );
        return;
      }

      AppUtils.showToastError(
        result.message.isNotEmpty ? result.message : 'Unable to open file',
      );
    } catch (e) {
      debugPrint('DocumentDownloadService: file open failure exception -> $e');
      AppUtils.showToastError('Unable to open file');
    }
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app needs permission to open files on your device.\n\n'
            'Please grant the required permission from the App Settings to continue.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> shareFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists() || await file.length() <= 0) {
        debugPrint('DocumentDownloadService: share failure -> file missing or empty: $filePath');
        AppUtils.showToastError('File not found');
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(filePath)],
        ),
      );
    } catch (e) {
      debugPrint('DocumentDownloadService: share failure -> $e');
      AppUtils.showToastError('Unable to share file');
    }
  }

  String sanitizeFileName(String input) {
    final String trimmed = input.trim();
    final String withoutExt = trimmed.contains('.')
        ? trimmed.substring(0, trimmed.lastIndexOf('.'))
        : trimmed;
    final String sanitized = withoutExt
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return sanitized.isEmpty ? 'document' : sanitized;
  }

  String resolvePreferredExtension({
    String? urlPath,
    String? displayName,
    String? contentType,
    List<int>? bytes,
  }) {
    final String byName = extractExtension(displayName ?? '');
    if (byName.isNotEmpty) {
      return byName;
    }

    final String byUrl = extractExtension(urlPath ?? '');
    if (byUrl.isNotEmpty) {
      return byUrl;
    }

    final String byType = extensionFromContentType(contentType);
    if (byType.isNotEmpty) {
      return byType;
    }

    final String bySignature = extensionFromBytes(bytes);
    if (bySignature.isNotEmpty) {
      return bySignature;
    }

    return '.bin';
  }

  String extractExtension(String value) {
    if (value.isEmpty) {
      return '';
    }

    final String clean = value.split('?').first.split('#').first;
    final String decoded = Uri.decodeComponent(clean);
    final int dotIndex = decoded.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == decoded.length - 1) {
      return '';
    }

    final String ext = decoded.substring(dotIndex).toLowerCase();
    final bool valid = RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(ext);
    if (!valid) {
      return '';
    }

    // Prevent date-like tails from being treated as file extensions (e.g. .2026).
    if (RegExp(r'^\.[0-9]+$').hasMatch(ext)) {
      return '';
    }

    return ext;
  }

  String extensionFromBytes(List<int>? bytes) {
    if (bytes == null || bytes.length < 4) {
      return '';
    }

    // PDF: %PDF
    if (bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return '.pdf';
    }

    // PNG
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }

    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return '.jpg';
    }

    // ZIP (also used by docx/xlsx/pptx containers)
    if (bytes[0] == 0x50 && bytes[1] == 0x4B) {
      return '.zip';
    }

    return '';
  }

  String extensionFromContentType(String? contentType) {
    if (contentType == null || contentType.trim().isEmpty) {
      return '';
    }
    final String ct = contentType.toLowerCase();
    if (ct.contains('pdf')) return '.pdf';
    if (ct.contains('msword')) return '.doc';
    if (ct.contains('wordprocessingml')) return '.docx';
    if (ct.contains('vnd.ms-excel')) return '.xls';
    if (ct.contains('spreadsheetml')) return '.xlsx';
    if (ct.contains('vnd.ms-powerpoint')) return '.ppt';
    if (ct.contains('presentationml')) return '.pptx';
    if (ct.contains('zip')) return '.zip';
    if (ct.contains('text/plain')) return '.txt';
    if (ct.contains('image/png')) return '.png';
    if (ct.contains('image/jpeg')) return '.jpg';
    if (ct.contains('image/webp')) return '.webp';
    if (ct.contains('audio/')) return '.mp3';
    if (ct.contains('video/')) return '.mp4';
    return '';
  }

  String mimeTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.ppt':
        return 'application/vnd.ms-powerpoint';
      case '.pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.txt':
        return 'text/plain';
      case '.zip':
        return 'application/zip';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.mp4':
        return 'video/mp4';
      default:
        return '';
    }
  }

  Future<void> _tryDelete(File file) async {
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {
        // Best-effort cleanup only.
      }
    }
  }
}

