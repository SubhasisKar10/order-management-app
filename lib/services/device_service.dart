import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static Future<Map<String, String>> getDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDeviceId =
        prefs.getString("device_id");

    final deviceId =
        savedDeviceId ?? const Uuid().v4();

    if (savedDeviceId == null) {
      await prefs.setString(
        "device_id",
        deviceId,
      );
    }

    String deviceName = "";

    if (Platform.isAndroid) {
      final android =
          await DeviceInfoPlugin().androidInfo;

      deviceName =
          "${android.manufacturer} ${android.model}";
    }

    return {
      "deviceId": deviceId,
      "deviceName": deviceName,
    };
  }
}