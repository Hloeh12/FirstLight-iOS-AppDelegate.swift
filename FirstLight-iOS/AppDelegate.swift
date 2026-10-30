import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = MainViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

class MainViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private var errorView: UIView?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 251/255, alpha: 1.0)
        setupWebView()
        loadApp()
    }

    private func setupWebView() {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.bounces = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        view.addSubview(webView)
    }

    private func loadApp() {
        if let localHTML = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "www") {
            let fileURL = URL(fileURLWithPath: localHTML)
            let accessURL = fileURL.deletingLastPathComponent()
            webView.loadFileURL(fileURL, allowingReadAccessTo: accessURL)
            return
        }

        if let loopbackURL = URL(string: "http://127.0.0.1:8765/?v=ipa") {
            webView.load(URLRequest(url: loopbackURL))
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(message: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(message: error.localizedDescription)
    }

    private func showError(message: String) {
        errorView?.removeFromSuperview()

        let container = UIView(frame: view.bounds)
        container.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 251/255, alpha: 1.0)

        let label = UILabel(frame: CGRect(x: 24, y: view.bounds.height / 2 - 80, width: view.bounds.width - 48, height: 100))
        label.text = "First Light · 初光\n\n离线资源载入失败: \(message)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 140/255, green: 140/255, blue: 154/255, alpha: 1.0)
        container.addSubview(label)

        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: view.bounds.width / 2 - 70, y: view.bounds.height / 2 + 40, width: 140, height: 44)
        btn.setTitle("重新载入", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 255/255, green: 79/255, blue: 139/255, alpha: 1.0)
        btn.layer.cornerRadius = 22
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        container.addSubview(btn)

        view.addSubview(container)
        errorView = container
    }

    @objc private func reloadTapped() {
        errorView?.removeFromSuperview()
        loadApp()
    }
}
