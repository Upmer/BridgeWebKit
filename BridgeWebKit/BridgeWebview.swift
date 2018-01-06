//
//  BridgeWebview.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2017/12/21.
//  Copyright © 2017年 upmer. All rights reserved.
//

import UIKit
import WebKit

protocol NatureBridge {
    
}

class BridgeWebview: WKWebView {
    
    var userContentController: WKUserContentController!
    
    convenience init(bridgeClass: AnyClass) {
        
        let injectJs: String = { () -> String in
            if let path = Bundle.main.path(forResource: "easyjs-inject", ofType: "js") {
                let js = try? String(contentsOfFile: path, encoding: .utf8)
                return js?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "") ?? ""
            } else {
                return ""
            }
        }()
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
        let injectScript = WKUserScript(source: injectJs, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectScript)
        debugPrint(BridgeParser.registerNatureFunction(bridgeClass: bridgeClass))
        userContentController.addUserScript(WKUserScript(source: BridgeParser.registerNatureFunction(bridgeClass: bridgeClass), injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        self.init(frame: CGRect.zero, configuration: configuration)
        
        
        self.userContentController = userContentController
        self.navigationDelegate = self
        self.uiDelegate = self
    }
    
    func addJavascript() {
        userContentController.add(self, name: "qsqapi")
    }
    
    func removeJavascript() {
        userContentController.removeScriptMessageHandler(forName: "qsqapi")
    }
    
    deinit {
        debugPrint("Bridge webview deinit")
    }
}

extension BridgeWebview: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("name: \(message.name), body: \(message.body), frameInfo: \(message.frameInfo)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString
        debugPrint(urlStr)
        decisionHandler(.allow)
    }
}

class BridgeParser {
    public static func registerNatureFunction(bridgeClass: AnyClass) -> String {
        var injection = "EasyJS.inject('"
        injection.append("qsqapi")
        injection.append("', [")
        
        var methodCount: CUnsignedInt = 0
        let mlist = class_copyMethodList(bridgeClass, &methodCount)
        print(methodCount)
        
        if let methodList = mlist {
            for i in 0..<Int(methodCount) {
                injection.append("'")
                let sel = sel_getName(method_getName(methodList[i]))
                let name = String(cString: sel)
                injection.append(name)
                injection.append("'")
                if i != Int(methodCount) - 1{
                    injection.append(", ")
                }
                print("functionName: \(name)")
            }
            free(mlist)
        }
        
        injection.append("]);")
        
        return injection
    }
}

class BridgeExecutor {
    func executorBridgeCallback() {
        
    }
    
    private func parserCallbackUrl(string: String) {
        guard string.hasPrefix("easy-js:") else {
            return
        }
        
        
    }
}
