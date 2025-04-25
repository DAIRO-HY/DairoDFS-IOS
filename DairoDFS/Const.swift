//
//  Const.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

import UIKit

///静态变量配置
enum Const {
//  ///标题字体
//  static const TITLE = 22.0;
//
//  ///普通字体大小
//  static const TEXT = 16.0;
//
//  ///小字体
//  static const TEXT_SMALL = 12.0;
//
//  ///普通圆角
//  static const RADIUS = 5.0;
//
//  static String get sd => "";

  ///获取设备唯一标识
    static var deviceId: String {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        return uuid.md5
  }
}
