//
//  SFSymbol.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/07.
//

import UIKit

/**
 SF Symbols图标名,较新的图标在旧系统上不存在,会显示空白
 */
enum SFSymbol {

    /// 系统有这个图标时使用它,否则使用替代图标
    /// - Parameter name 图标名
    /// - Parameter fallback 旧系统上使用的替代图标
    static func name(_ name: String, fallback: String) -> String {
        return UIImage(systemName: name) != nil ? name : fallback
    }
}
