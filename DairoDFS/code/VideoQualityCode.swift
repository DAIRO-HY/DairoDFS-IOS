//
//  VideoQualityCode.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

///视频画质值
struct VideoQualityCode {
    ///原画
    static let NORMAL = 0
    
    ///高清
    static let HIGHT = 1920
    
    ///标清
    static let MID = 1280
    
    ///流畅
    static let LOW = 640
    
    ///code值转显示标题
    static func codeLabel(code: Int) -> String {
        switch code {
        case HIGHT:
            return "高清"
        case MID:
            return "标清"
        case LOW:
            return "流畅"
        case NORMAL:
            return "原画"
        default:
            return "未知"
        }
    }
    
    ///获取所有的值
    static var codes: [Int] {
        return [NORMAL,HIGHT,MID,LOW]
    }
}
