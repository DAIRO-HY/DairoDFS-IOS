//
//  ShareNotification.swift
//  DairoDFSShare
//
//  Created by zhoulq on 2026/11/23.
//

import UserNotifications

/// 分享完成之后提醒用户打开App上传,点击通知会打开主App
enum ShareNotification {

    static func show(count: Int) async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else{
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "已添加\(count)个文件"
        content.body = "点此打开DairoDFS开始上传"
        content.sound = .default

        //同一个ID的通知会被替换,只保留最后一次分享的提醒
        let request = UNNotificationRequest(identifier: ShareUploadStore.NOTIFICATION_ID, content: content, trigger: nil)
        try? await center.add(request)
    }
}
