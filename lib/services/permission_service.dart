import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  final DeviceInfoPlugin _deviceInfo;

  PermissionService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<int?> getAndroidSdk() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
      final int sdk = info.version.sdkInt;
      debugPrint('PermissionService: detected Android SDK $sdk');
      return sdk;
    } catch (e) {
      debugPrint('PermissionService: failed to read Android SDK: $e');
      return null;
    }
  }

  Future<bool> ensureDownloadWriteAccess() async {
    // Downloads are saved to the app's own external-files directory
    // (see DocumentDownloadService.resolveDefaultDownloadsDirectory), which
    // has never required WRITE_EXTERNAL_STORAGE on any Android version.
    // Only the public Downloads/shared-storage directories need that
    // permission, and this app no longer writes there.
    return true;
  }
}

