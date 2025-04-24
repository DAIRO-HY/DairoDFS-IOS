import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dairo_dfs_app/extension/String++.dart';
import 'package:dairo_dfs_app/util/SyncVariable.dart';

///静态变量配置
class Const {
  ///标题字体
  static const TITLE = 22.0;

  ///普通字体大小
  static const TEXT = 16.0;

  ///小字体
  static const TEXT_SMALL = 12.0;

  ///普通圆角
  static const RADIUS = 5.0;

  static String get sd => "";

  ///获取设备唯一标识
  static Future<String> get deviceId async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // 使用 Android ID 作为设备唯一标识
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor; // 使用 identifierForVendor 作为设备唯一标识
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      deviceId = windowsInfo.deviceId;
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      deviceId = linuxInfo.id;
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo linuxInfo = await deviceInfo.macOsInfo;
      deviceId = linuxInfo.systemGUID;
    } else {
      ;
    }
    if (deviceId == null) {
      final uniqueTagFile = File(SyncVariable.supportPath + "/unique_tag");
      if (uniqueTagFile.existsSync()) {
        deviceId = uniqueTagFile.readAsStringSync();
      } else {
        deviceId = DateTime
            .now()
            .microsecondsSinceEpoch
            .toString() + Random().nextInt(100000000000).toString();
        uniqueTagFile.createSync(recursive: true);
        uniqueTagFile.writeAsStringSync(deviceId);
      }
    }
    return deviceId.md5;
  }
}
