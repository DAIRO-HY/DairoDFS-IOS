//
//  AlbumGroup.swift
//  DairoDFS
//

import Foundation

/// 相册的显示方式
enum AlbumViewMode{
    
    /// 按年分组
    case year
    
    /// 按月分组
    case month
    
    /// 显示全部照片
    case all
}

/// 分组里的一张照片
struct AlbumGroupPhoto: Identifiable{
    
    let fm: FileModel
    
    /// 照片左上角显示的日期,按月分组时是:4日,按年分组时是:11月4日
    let dateLabel: String
    
    var id: Int64{
        return self.fm.id
    }
}

/// 一个分组,对应一年或者一个月
struct AlbumGroup: Identifiable{
    
    /// 分组标题,比如:2026年、2026年11月
    let title: String
    
    /// 这个分组要显示的照片,最多4张
    let photos: [AlbumGroupPhoto]
    
    var id: String{
        return self.title
    }
}

/// 把相册的照片整理成分组
enum AlbumGroupBuilder{
    
    /// 每组最多显示的照片数
    private static let MAX_PHOTO_COUNT = 4
    
    /// 按年分组
    /// - Parameter fileModels 相册的全部照片,要求已经按拍摄时间排好序
    static func buildYearGroups(_ fileModels: [FileModel]) -> [AlbumGroup]{
        return self.build(fileModels, getTitle: { "\($0.year!)年" }, getDateLabel: { "\($0.month!)月\($0.day!)日" })
    }
    
    /// 按月分组
    /// - Parameter fileModels 相册的全部照片,要求已经按拍摄时间排好序
    static func buildMonthGroups(_ fileModels: [FileModel]) -> [AlbumGroup]{
        return self.build(fileModels, getTitle: { "\($0.year!)年\($0.month!)月" }, getDateLabel: { "\($0.day!)日" })
    }
    
    /// 整理分组
    /// - Parameter fileModels 相册的全部照片,要求已经按拍摄时间排好序
    /// - Parameter getTitle 根据拍摄日期得到分组标题,标题相同的照片属于同一组
    /// - Parameter getDateLabel 根据拍摄日期得到照片左上角显示的日期
    private static func build(_ fileModels: [FileModel], getTitle: (DateComponents) -> String, getDateLabel: (DateComponents) -> String) -> [AlbumGroup]{
        var groups = [AlbumGroup]()
        
        //当前分组的标题
        var currentTitle = ""
        
        //当前分组里每天的第一张照片
        var firstPhotos = [AlbumGroupPhoto]()
        
        //上一张照片的拍摄日期,用来判断是不是新的一天
        var lastDate: DateComponents?
        for fm in fileModels{
            let date = Calendar.current.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: Double(fm.date) / 1000))
            let title = getTitle(date)
            if title != currentTitle{//进入了新的分组,把上一个分组保存起来
                if !firstPhotos.isEmpty{
                    groups.append(AlbumGroup(title: currentTitle, photos: self.pickPhotos(firstPhotos)))
                }
                currentTitle = title
                firstPhotos.removeAll()
                lastDate = nil
            }
            if date != lastDate{//这一天的第一张照片
                firstPhotos.append(AlbumGroupPhoto(fm: fm, dateLabel: getDateLabel(date)))
                lastDate = date
            }
        }
        if !firstPhotos.isEmpty{//保存最后一个分组
            groups.append(AlbumGroup(title: currentTitle, photos: self.pickPhotos(firstPhotos)))
        }
        return groups
    }
    
    /// 从每天的第一张照片里,按相同的间隔取出要显示的照片
    /// 比如有30天有照片,间隔是30/4=7,取第1、8、15、22天。有10天有照片,间隔是10/4=2,取第1、3、5、7天
    /// - Parameter firstPhotos 每天的第一张照片
    static func pickPhotos(_ firstPhotos: [AlbumGroupPhoto]) -> [AlbumGroupPhoto]{
        if firstPhotos.count <= MAX_PHOTO_COUNT{//不够4天就全部显示
            return firstPhotos
        }
        let step = firstPhotos.count / MAX_PHOTO_COUNT
        return (0 ..< MAX_PHOTO_COUNT).map{ firstPhotos[$0 * step] }
    }
}
