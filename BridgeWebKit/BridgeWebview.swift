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
    
    convenience init() {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        self.init(frame: CGRect.zero, configuration: configuration)
        self.userContentController = userContentController
        self.navigationDelegate = self
        self.uiDelegate = self
    }
    
    func addJavascript() {
        userContentController.add(self, name: "sayhello")
    }
    
    func removeJavascript() {
        userContentController.removeScriptMessageHandler(forName: "sayhello")
    }
    
    deinit {
        debugPrint("Bridge webview deinit")
    }
    
    func registerNatureFunction(bridgeClass: AnyClass) {
        
        var injecttion = "EasyJS.inject(\""
        injecttion.append("qsqapi")
        injecttion.append("\", [")
        
        var methodCount: CUnsignedInt = 0
        let mlist = class_copyMethodList(bridgeClass, &methodCount)
        print(methodCount)
        
        if let methodList = mlist {
            for i in 0..<Int(methodCount) {
                injecttion.append("\"")
                let sel = sel_getName(method_getName(methodList[i]))
                let name = String(cString: sel)
                injecttion.append(name)
                injecttion.append("\"")
                if i != Int(methodCount) - 1{
                    injecttion.append(", ")
                }
                print("functionName: \(name)")
            }
            free(mlist)
        }
        
        injecttion.append("]);")
        debugPrint(injecttion)
    }
}

extension BridgeWebview: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("name: \(message.name), body: \(message.body), frameInfo: \(message.frameInfo)")
    }
}
