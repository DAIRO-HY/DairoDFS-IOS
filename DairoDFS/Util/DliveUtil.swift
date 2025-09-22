import Foundation
import DairoUI_IOS

// DliveInfo 实况照片信息
struct DliveInfo {
    
    //照片格式
    let photoExt: String
    
    //照片数据
    let photoData: Data
    
    //照片文件大小
    let photoSize: Int
    
    //视频格式
    let videoExt: String
    
    //视频数据
    let videoData: Data
    
    //视频文件大小
    let videoSize: Int
}

class DliveUtil {
    
    // 获取实况照片信息
    static func getInfo(_ path: String) -> DliveInfo {
        let data = FileUtil.readAll(path)
        return getInfo(data!)
    }
    
    // 获取实况照片信息
    static func getInfo(_ data: Data) -> DliveInfo {
        
        //获取减号所在的位置
        let headEndIndex = data.firstIndex(of: 0x2D)!
        let head = String(data: data[..<headEndIndex], encoding: .utf8)!
        let headArr = head.split(separator: "|")
        
        let photoExt = headArr[1]                   //图片格式
        let photoSize = Int(headArr[2])! //图片文件大小
        let photoData = data[(headEndIndex + 1)...headEndIndex + photoSize]
        let videoExt = headArr[3]
        let videoSize = data.count - photoSize - head.count - 1
        let videoData = data[(data.count - videoSize)...]
        return DliveInfo(
            photoExt: String(photoExt),
            photoData: photoData,
            photoSize: photoSize,
            videoExt: String(videoExt),
            videoData: videoData,
            videoSize: videoSize
        )
    }
}
