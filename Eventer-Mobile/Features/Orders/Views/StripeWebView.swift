import SwiftUI
import WebKit

struct StripeWebView: UIViewRepresentable {
    let url: URL
    let onSuccess: () -> Void
    let onCancel: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: StripeWebView
        
        init(_ parent: StripeWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let urlString = url.absoluteString
            
            if urlString.contains("/events/success") {
                decisionHandler(.cancel)
                parent.onSuccess()
                return
            }
            
            if urlString.contains("/events/canceled") {
                decisionHandler(.cancel)
                parent.onCancel()
                return
            }
            
            decisionHandler(.allow)
        }
    }
}
