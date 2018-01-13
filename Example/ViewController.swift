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
        
        let exam = ExampleBridge()
        
        let async = ["sysPlatform": exam.sysPlatform]
        let webview = BridgeWebview(bridge: exam, injectJs: async);
        webview.frame = view.bounds
        
        webview.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)))
//        webview.load(URLRequest(url: URL(string: "http://172.16.28.238:1123/#!/example/dsqapitest")!))
        view.addSubview(webview)
        self.webview = webview
        
//        perform(#selector(update), with: nil, afterDelay: 10)
    }
    
    @objc func update() {
        webview.updateSyncProperty()
    }
    
    deinit {
        debugPrint("webview controller deinit")
    }
}

