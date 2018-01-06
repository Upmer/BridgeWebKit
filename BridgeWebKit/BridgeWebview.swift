//
//  BridgeWebview.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2017/12/21.
//  Copyright © 2017年 upmer. All rights reserved.
//

import UIKit
import WebKit

class NatureBridge: NSObject { }

class BridgeWebview: WKWebView {
    
    var userContentController: WKUserContentController!
    
    var bridge: NatureBridge!
    
    convenience init(bridge: NatureBridge) {
        
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
        let cls: AnyClass = object_getClass(bridge)!
        let injectScript = WKUserScript(source: injectJs, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectScript)
        debugPrint(BridgeParser.registerNatureFunction(bridgeClass: cls))
        userContentController.addUserScript(WKUserScript(source: BridgeParser.registerNatureFunction(bridgeClass: cls), injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        self.init(frame: CGRect.zero, configuration: configuration)
        
        self.bridge = bridge
        
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
        BridgeExecutor().executorBridgeCallback(url: urlStr ?? "", bridge: bridge)
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
    func executorBridgeCallback(url: String, bridge: NatureBridge) {
        if let method = parserCallbackUrl(string: url) {
            let selector = NSSelectorFromString(method)
            bridge.perform(selector)
//            bridge.performSelector(onMainThread: <#T##Selector#>, with: <#T##Any?#>, waitUntilDone: <#T##Bool#>)
        }
    }
    
    private func parserCallbackUrl(string: String) -> String? {
        guard string.hasPrefix("easy-js:") else {
            return nil
        }
        
        let components = string.components(separatedBy: ":")
        let method = components[2]
        return method
    }
}
