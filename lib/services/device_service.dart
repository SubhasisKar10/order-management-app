import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static Future<Map<String, String>> getDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    String? deviceId = prefs.getString("device_id");

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString("device_id", deviceId);
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