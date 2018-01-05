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
        
        let webview = BridgeWebview()
        webview.frame = view.bounds
        
//        webview.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)))
        webview.load(URLRequest(url: URL(string: "http://api.testing-cash.kuainiujinke.com/vue/#/jsbridge")!))
        view.addSubview(webview)
        self.webview = webview
        let example = ExampleBridge()
        webview.registerNatureFunction(bridgeClass: ExampleBridge.self)
    }
    
    deinit {
        debugPrint("webview controller deinit")
        webview.removeJavascript()
    }
}


