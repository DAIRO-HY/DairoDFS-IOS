import SwiftUI
import Combine

class ToastManager: ObservableObject {
    static let shared = ToastManager() // 单例

    @Published var message: String = ""
    @Published var show: Bool = false

    private var timer: AnyCancellable?

    private init() {}

    func showToast(_ text: String, duration: TimeInterval = 2) {
        message = text
        withAnimation {
            show = true
        }

        // 自动隐藏
        timer?.cancel()
        timer = Just(())
            .delay(for: .seconds(duration), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.show = false
                }
            }
    }
}
