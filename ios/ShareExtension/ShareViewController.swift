import UIKit

/// iOS Share Extension ViewController
/// 외부 앱(유튜브 등)에서 공유 시 URL/텍스트를 App Groups UserDefaults에 저장하고
/// storoo:// URL 스킴으로 메인 앱을 열어 저장 시트를 띄운다.
class ShareViewController: UIViewController {

    private let appGroupId = "group.com.example.storoo"
    private let mainAppUrl = URL(string: "storoo://share")!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extractSharedItem()
    }

    private func extractSharedItem() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            finish()
            return
        }

        // URL 타입 우선 처리 (iOS 12+ 호환 문자열 식별자 사용)
        if provider.hasItemConformingToTypeIdentifier("public.url") {
            provider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] item, _ in
                let text: String?
                if let url = item as? URL {
                    text = url.absoluteString
                } else {
                    text = item as? String
                }
                self?.saveAndLaunch(type: "link", text: text)
            }
        } else if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
            provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [weak self] item, _ in
                let text = item as? String
                let isURL = text.flatMap {
                    $0.range(of: "https?://", options: .regularExpression)
                } != nil
                self?.saveAndLaunch(type: isURL ? "link" : "note", text: text)
            }
        } else {
            finish()
        }
    }

    private func saveAndLaunch(type: String, text: String?) {
        let defaults = UserDefaults(suiteName: appGroupId)
        defaults?.set(type, forKey: "shareType")
        defaults?.set(text, forKey: "shareText")
        defaults?.synchronize()
        // 메인 앱 열기 (Share Extension에서 NSExtensionContext.open 사용)
        extensionContext?.open(mainAppUrl, completionHandler: nil)
        finish()
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
