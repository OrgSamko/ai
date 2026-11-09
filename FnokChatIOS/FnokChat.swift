import SwiftUI
import UIKit
import WebKit

@main
struct FnokChatApp: App {
    var body: some Scene {
        WindowGroup {
            ChatScreen()
                .statusBarHidden(true)
                .background(Color.black.ignoresSafeArea())
        }
    }
}

struct ChatScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ChatViewController {
        ChatViewController()
    }

    func updateUIViewController(_ controller: ChatViewController, context: Context) {}
}

final class ChatViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let home = URL(string: "https://fnokchat.onrender.com/")!
    private var webView: WKWebView!
    private let retryButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        var buttonStyle = UIButton.Configuration.filled()
        buttonStyle.title = "Načíst chat znovu"
        retryButton.configuration = buttonStyle
        retryButton.addTarget(self, action: #selector(loadChat), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        loadChat()
    }

    @objc private func loadChat() {
        retryButton.isHidden = true
        webView.isHidden = false
        webView.load(URLRequest(url: home))
    }

    private func showRetry() {
        webView.isHidden = true
        retryButton.isHidden = false
    }

    private func isChatURL(_ url: URL) -> Bool {
        url.scheme == "https" && url.host == home.host && (url.port == nil || url.port == 443)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor action: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = action.request.url else {
            decisionHandler(.cancel)
            return
        }
        if action.targetFrame?.isMainFrame == false {
            decisionHandler(.allow)
        } else if isChatURL(url) {
            if action.targetFrame == nil {
                decisionHandler(.cancel)
                webView.load(action.request)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.cancel)
            if let scheme = url.scheme, ["https", "http", "mailto", "tel"].contains(scheme) {
                UIApplication.shared.open(url)
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping @MainActor @Sendable (WKPermissionDecision) -> Void
    ) {
        let trusted = origin.protocol == "https" && origin.host == home.host
            && (origin.port == 0 || origin.port == 443)
        decisionHandler(trusted ? .prompt : .deny)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        showRetry()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled { showRetry() }
    }
}
