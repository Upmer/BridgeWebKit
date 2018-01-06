//
//  ViewController.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2017/12/21.
//  Copyright © 2017年 upmer. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    weak var webview: BridgeWebview!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webview = BridgeWebview(bridgeClass: ExampleBridge.self)
        webview.frame = view.bounds
        
        webview.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)))
//        webview.load(URLRequest(url: URL(string: "http://172.16.28.238:1123/#!/example/dsqapitest")!))
        view.addSubview(webview)
        self.webview = webview
//        webview.addJavascript()
        
        
    }
    
    deinit {
        debugPrint("webview controller deinit")
        webview.removeJavascript()
    }
}


