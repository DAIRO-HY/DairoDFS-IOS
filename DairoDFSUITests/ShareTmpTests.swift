import XCTest

final class ShareTmpTests: XCTestCase {
    func testTapNotification() throws {
        let app = XCUIApplication(bundleIdentifier: "cn.dairo.dfs")
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        print("APPSTATE0=\(app.state.rawValue)")
        let start = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.0))
        start.press(forDuration: 0.3, thenDragTo: springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.7)))
        sleep(2)
        let n = springboard.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS '点此打开DairoDFS'")).firstMatch
        XCTAssertTrue(n.waitForExistence(timeout: 5))
        n.tap()
        sleep(8)
        print("APPSTATE=\(app.state.rawValue)")
    }
}
