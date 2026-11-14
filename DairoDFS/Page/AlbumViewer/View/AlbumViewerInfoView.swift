//
//  AlbumViewerInfoView.swift
//  DairoDFS
//

import SwiftUI
import DairoUI_IOS

/// 文件属性JSON里的图片、视频信息,没有的字段服务端不会返回
struct AlbumViewerMediaInfo: Decodable {
    var width: Int?
    var height: Int?
    var date: Int64?
    var originalDate: Int64?
    var make: String?
    var camera: String?
    var lens: String?
    var focalLength: String?
    var focalLength35: Int?
    var fNumber: String?
    var shutterSpeed: String?
    var iso: Int?
    var lat: Double?
    var long: Double?
    var orientation: Int?
    var fps: Double?
    var bitrate: Int64?
    var duration: Int64?
    
    init?(_ property: String){
        guard let data = property.data(using: .utf8),
              let info = try? JSONDecoder().decode(AlbumViewerMediaInfo.self, from: data) else{
            return nil
        }
        self = info
    }
    
    /// 设备名称,型号一般已经能说明设备,没有型号时才显示制造商
    var device: String?{
        if let camera, !camera.isEmpty{
            return camera
        }
        return self.make
    }
    
    /// 焦距,和系统相册一样优先显示等效35mm焦距
    var focalLabel: String?{
        if let focalLength35{
            return "\(focalLength35) mm"
        }
        guard let focalLength, !focalLength.isEmpty else{
            return nil
        }
        return "\(focalLength) mm"
    }
    
    /// 尺寸,照片要旋转90度显示时宽高调换
    var sizeLabel: String?{
        guard let width, let height else{
            return nil
        }
        return [5, 6, 7, 8].contains(self.orientation) ? "\(height) × \(width)" : "\(width) × \(height)"
    }
    
    /// 像素数
    var megapixelLabel: String?{
        guard let width, let height else{
            return nil
        }
        return String(format: "%.1f MP", Double(width * height) / 1_000_000)
    }
    
    /// 帧率
    var fpsLabel: String?{
        return self.fps.map{ String(format: "%g fps", $0) }
    }
    
    /// 视频比特率
    var bitrateLabel: String?{
        guard let bitrate else{
            return nil
        }
        return bitrate >= 1_000_000 ? String(format: "%.1f Mbps", Double(bitrate) / 1_000_000) : "\(bitrate / 1000) kbps"
    }
    
    /// 坐标
    var locationLabel: String?{
        guard let lat, let long else{
            return nil
        }
        return String(format: "%.5f, %.5f", lat, long)
    }
    
    /// 拍摄参数,照片是ISO、焦距、光圈、快门,视频是时长、比特率
    var parameters: [String]{
        var list = [String]()
        if let iso{
            list.append("ISO \(iso)")
        }
        if let focalLabel{
            list.append(focalLabel)
        }
        if let fNumber, !fNumber.isEmpty{
            list.append("ƒ\(fNumber)")
        }
        if let shutterSpeed, !shutterSpeed.isEmpty{
            list.append("\(shutterSpeed) s")
        }
        if let duration{
            list.append(duration.timeFormat)
        }
        if let bitrateLabel{
            list.append(bitrateLabel)
        }
        return list
    }
}

/// 属性面板
struct AlbumViewerInfoView: View {
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    /// 修改拍摄时间页面是否显示
    @State private var showCaptureTime = false
    
    var body: some View {
        Group{
            if let property = self.vm.fileProperty{
                self.getContent(property)
            } else if self.vm.propertyIsLoading{
                ProgressView()
            } else {
                Button("加载失败，点击重试", action: self.vm.onInfoClick)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .infoSheetDetents()
    }
    
    private func getContent(_ property: FilePropertyModel) -> some View{
        let info = AlbumViewerMediaInfo(property.property)
        return ScrollView{
            VStack(alignment: .leading, spacing: 16){
                VStack(alignment: .leading, spacing: 4){
                    Text(property.name)
                        .font(.headline)
                    HStack{
                        if let fileTime = self.vm.fileTime{
                            Text(fileTime)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("调整"){
                            self.showCaptureTime = true
                        }
                        .font(.subheadline)
                    }
                }
                self.getMediaCard(property, info)
                VStack(alignment: .leading, spacing: 12){
                    self.getRow("文件路径", property.path)
                    if let location = info?.locationLabel{
                        self.getRow("拍摄位置", location)
                    }
                    if property.uploadDate > 0{
                        self.getRow("上传时间", Date(timeIntervalSince1970: Double(property.uploadDate) / 1000).format())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom)
        }
        .sheet(isPresented: self.$showCaptureTime){
            AlbumViewerCaptureTimeView(
                date: info?.date.flatMap{ $0 > 0 ? $0 : nil } ?? property.uploadDate,
                isModified: info?.originalDate != nil
            )
            .environmentObject(self.vm)
        }
    }
    
    /// 设备、尺寸和拍摄参数
    private func getMediaCard(_ property: FilePropertyModel, _ info: AlbumViewerMediaInfo?) -> some View{
        let labels = [info?.sizeLabel, self.vm.isVideo ? info?.fpsLabel : info?.megapixelLabel, property.size].compactMap{ $0 }
        let parameters = info?.parameters ?? []
        return VStack(alignment: .leading, spacing: 10){
            if let device = info?.device{
                Text(device)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            if let lens = info?.lens, !lens.isEmpty{
                Text(lens)
                    .font(.subheadline)
            }
            Text(labels.joined(separator: " · "))
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !parameters.isEmpty{
                Divider()
                HStack{
                    ForEach(parameters, id: \.self){
                        Text($0)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func getRow(_ label: String, _ value: String) -> some View{
        return VStack(alignment: .leading, spacing: 2){
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)
        }
    }
}

/// 修改拍摄时间页面,只修改服务器上记录的时间,不修改文件本身
struct AlbumViewerCaptureTimeView: View {
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    /// 打开页面时的时间
    private let originalDate: Date
    
    /// 拍摄时间是否被修改过
    private let isModified: Bool
    
    /// 当前选择的时间
    @State private var date: Date
    
    /// 是否正在保存
    @State private var isSaving = false
    
    /// 保存失败的错误信息,面板盖在页面上面,Toast会被挡住
    @State private var errorMsg: String?
    
    /// - Parameter date 当前拍摄时间(毫秒)
    /// - Parameter isModified 拍摄时间是否被修改过
    init(date: Int64, isModified: Bool){
        let date = Date(timeIntervalSince1970: Double(date) / 1000)
        self.originalDate = date
        self.isModified = isModified
        self._date = State(initialValue: date)
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 16){
                    DatePicker("拍摄时间", selection: self.$date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                    if let errorMsg = self.errorMsg{
                        Text(errorMsg)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    if self.isModified{
                        Button("恢复原始时间"){
                            self.save(0)
                        }
                        .disabled(self.isSaving)
                    }
                }
                .padding()
            }
            .navigationTitle("调整日期与时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("取消"){
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    if self.isSaving{
                        ProgressView()
                    } else {
                        Button("保存"){
                            self.save(Int64(self.date.timeIntervalSince1970 * 1000))
                        }
                        .disabled(self.date == self.originalDate)
                    }
                }
            }
        }
        //iPad上默认是左右分栏,这里要全屏显示
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled(self.isSaving)
    }
    
    /// 保存拍摄时间
    /// - Parameter date 拍摄时间(毫秒),0代表恢复成照片本身的拍摄时间
    private func save(_ date: Int64){
        self.isSaving = true
        self.errorMsg = nil
        self.vm.updateCaptureTime(date){
            self.isSaving = false
            if let error = $0{
                self.errorMsg = error
                return
            }
            self.dismiss()
        }
    }
}

private extension View{
    
    /// 面板先显示一半高度,可以上拉到全屏,iOS 16以下系统不支持,只能全屏显示
    @ViewBuilder
    func infoSheetDetents() -> some View{
        if #available(iOS 16.0, *){
            self.presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}
