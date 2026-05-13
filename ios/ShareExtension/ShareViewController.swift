import UIKit

/// iOS Share Extension ViewController
/// 외부 앱에서 공유 시 URL/텍스트/이미지(최대 5장)를 App Groups에 저장하고
/// Responder Chain을 통해 메인 앱(storoo://)을 연다.
class ShareViewController: UIViewController {

    private let appGroupId = "group.com.example.storoo"
    private let mainAppUrl = URL(string: "storoo://share")!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extractSharedItems()
    }

    private func extractSharedItems() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments, !attachments.isEmpty else {
            finish()
            return
        }

        let imageProviders = attachments.filter {
            $0.hasItemConformingToTypeIdentifier("public.image")
        }

        if !imageProviders.isEmpty {
            saveImages(from: Array(imageProviders.prefix(5)))
            return
        }

        guard let provider = attachments.first else { finish(); return }

        if provider.hasItemConformingToTypeIdentifier("public.url") {
            provider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] item, _ in
                let text: String?
                if let url = item as? URL {
                    text = url.absoluteString
                } else {
                    text = item as? String
                }
                self?.saveLinkOrNote(type: "link", text: text)
            }
        } else if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
            provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [weak self] item, _ in
                let text = item as? String
                let isURL = text.flatMap {
                    $0.range(of: "https?://", options: .regularExpression)
                } != nil
                self?.saveLinkOrNote(type: isURL ? "link" : "note", text: text)
            }
        } else {
            finish()
        }
    }

    // MARK: - Image

    private func saveImages(from providers: [NSItemProvider]) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            finish()
            return
        }

        let group = DispatchGroup()
        var paths: [String] = Array(repeating: "", count: providers.count)
        let timestamp = Int(Date().timeIntervalSince1970)

        for (index, provider) in providers.enumerated() {
            group.enter()
            provider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, _ in
                defer { group.leave() }

                var imageData: Data?
                if let url = item as? URL {
                    imageData = try? Data(contentsOf: url)
                } else if let data = item as? Data {
                    imageData = data
                } else if let image = item as? UIImage {
                    imageData = image.jpegData(compressionQuality: 0.9)
                }

                guard let data = imageData else { return }
                let fileName = "share_img_\(timestamp)_\(index).jpg"
                let fileURL = containerURL.appendingPathComponent(fileName)
                try? data.write(to: fileURL)
                paths[index] = fileURL.path
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let validPaths = paths.filter { !$0.isEmpty }
            let defaults = UserDefaults(suiteName: self.appGroupId)
            defaults?.set("image", forKey: "shareType")
            defaults?.set(validPaths, forKey: "shareImagePaths")
            defaults?.synchronize()
            self.openMainApp()
            self.finish()
        }
    }

    // MARK: - Link / Note

    private func saveLinkOrNote(type: String, text: String?) {
        let defaults = UserDefaults(suiteName: appGroupId)
        defaults?.set(type, forKey: "shareType")
        defaults?.set(text, forKey: "shareText")
        defaults?.synchronize()
        openMainApp()
        finish()
    }

    // MARK: - Helpers

    // Share Extension에서 extensionContext?.open()은 iOS 13+에서 동작하지 않으므로
    // Responder Chain을 통해 UIApplication을 찾아 openURL을 수행한다.
    private func openMainApp() {
        var responder: UIResponder? = self
        while let r = responder {
            if r.responds(to: NSSelectorFromString("openURL:")) {
                r.perform(NSSelectorFromString("openURL:"), with: mainAppUrl)
                return
            }
            responder = r.next
        }
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
