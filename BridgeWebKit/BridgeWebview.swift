//
//  BridgeWebview.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2017/12/21.
//  Copyright © 2017年 upmer. All rights reserved.
//

import UIKit
import WebKit

class NatureBridge: NSObject {
    weak var webView: BridgeWebview!
}

class BridgeWebview: WKWebView {
    
    var userContentController: WKUserContentController!
    
    var bridge: NatureBridge!
    
    private var syncObjs: [String: (() -> String)] = [:]
    
    convenience init(bridge: NatureBridge, injectJs: [String: (() -> String)]) {
        
        let baseJs: String = { () -> String in
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
        // 1. base js
        let injectScript = WKUserScript(source: baseJs, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectScript)
        
        // 2.
        for (p, f) in injectJs {
            let js = "EasyJS.syncProperty.\(p)=\(f());"
            debugPrint(js, f)
            userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        }
        
        userContentController.addUserScript(WKUserScript(source: BridgeParser.registerNatureFunction(bridgeClass: cls), injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        self.init(frame: CGRect.zero, configuration: configuration)
        
        bridge.webView = self
        self.bridge = bridge
        self.syncObjs = injectJs
        
        self.userContentController = userContentController
        self.navigationDelegate = self
        self.uiDelegate = self
    }
    
    func updateSyncProperty() {
        var js = "(function() {"
        for (p, f) in syncObjs {
            js += "EasyJS.syncProperty.\(p)=\(f());"
        }
        js += "})();"
        debugPrint(js)
        evaluateJavaScript(js, completionHandler: nil)
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
        debugPrint(urlStr?.replacingOccurrences(of: "%3A", with: ":"))
        BridgeExecutor().executorBridgeCallback(url: urlStr ?? "", bridge: bridge)
        decisionHandler(.allow)
        
    }
}

class BridgeParser {
    public static func registerNatureFunction(bridgeClass: AnyClass) -> String {
        var injection = "EasyJS.inject('"
        injection.append("dsqapi")
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
        debugPrint(injection)
        
        return injection
    }
}

class BridgeExecutor: NSObject {
    func executorBridgeCallback(url: String, bridge: NatureBridge) {
        let result: (String?, [String]) = parserCallbackUrl(string: url)
        if let method = result.0 {
            debugPrint(method)
            // openView(_ type: String, _ jsonToString: String)
            let selector = NSSelectorFromString(method)
            
            BridgeInvocation.excuteNatureBridge(withMethod: method, argments: result.1, interface: bridge)
        }
    }
    
    private func parserCallbackUrl(string: String) -> (String?, [String]) {
        guard string.hasPrefix("easy-js:") else {
            return (nil, [])
        }
        
        let components = string.components(separatedBy: "?")
        let objs = components[0].components(separatedBy: ":")
        
        var args: [String] = []
        if components.count > 1 {
            args = components[1].replacingOccurrences(of: "%26", with: "&").components(separatedBy: "&")
        }
        let method: String? = objs[2].replacingOccurrences(of: "%3A", with: ":")
        debugPrint(args)
        return (method, args)
        /*
         
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
         messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
         */
    }
}
