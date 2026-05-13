import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var pendingShareType: String?
    private var pendingShareText: String?
    private var pendingImagePaths: [String] = []
    private var shareChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // URL 스킴으로 콜드 스타트한 경우 공유 데이터를 먼저 읽는다
        if let url = launchOptions?[.url] as? URL {
            readShareData(from: url)
        }

        setupShareChannel()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 앱이 이미 실행 중일 때 storoo://share 로 열리는 경우
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard readShareData(from: url) else { return false }
        shareChannel?.invokeMethod("onShareReceived", arguments: nil)
        return true
    }

    private func setupShareChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        shareChannel = FlutterMethodChannel(
            name: "com.example.storoo/share",
            binaryMessenger: controller.binaryMessenger
        )
        shareChannel?.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            switch call.method {
            case "isShareLaunch":
                result(self.pendingShareType != nil)
            case "getShareType":
                result(self.pendingShareType ?? "link")
            case "getSharedText":
                let text = self.pendingShareText
                self.pendingShareType = nil
                self.pendingShareText = nil
                result(text)
            case "getImagePaths":
                let paths = self.pendingImagePaths
                self.pendingImagePaths = []
                result(paths)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @discardableResult
    private func readShareData(from url: URL) -> Bool {
        guard url.scheme == "storoo" else { return false }
        let defaults = UserDefaults(suiteName: "group.com.example.storoo")
        pendingShareType = defaults?.string(forKey: "shareType") ?? "link"
        pendingShareText = defaults?.string(forKey: "shareText")
        pendingImagePaths = defaults?.stringArray(forKey: "shareImagePaths") ?? []
        defaults?.removeObject(forKey: "shareType")
        defaults?.removeObject(forKey: "shareText")
        defaults?.removeObject(forKey: "shareImagePaths")
        defaults?.synchronize()
        return true
    }
}
