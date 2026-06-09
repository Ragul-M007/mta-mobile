import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

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
    if (!Platform.isAndroid) {
      debugPrint('PermissionService: non-Android platform, no storage permission required');
      return true;
    }

    final int? sdk = await getAndroidSdk();
    if (sdk == null) {
      // Avoid false negatives from device-info failures on modern Android.
      debugPrint('PermissionService: SDK unknown, allowing scoped-storage flow');
      return true;
    }

    if (sdk <= 28) {
      final PermissionStatus status = await Permission.storage.status;
      if (status.isGranted || status.isLimited || status.isProvisional) {
        debugPrint('PermissionService: storage permission already granted for SDK $sdk');
        return true;
      }

      final PermissionStatus requested = await Permission.storage.request();
      final bool granted = requested.isGranted ||
          requested.isLimited ||
          requested.isProvisional;

      debugPrint(
        granted
            ? 'PermissionService: storage permission granted for SDK $sdk'
            : 'PermissionService: storage permission denied for SDK $sdk',
      );

      return granted;
    }

    debugPrint('PermissionService: scoped storage active for SDK $sdk, no storage permission requested');
    return true;
  }
}

