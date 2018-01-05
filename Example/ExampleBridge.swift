//
//  ExampleBridge.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2018/1/5.
//  Copyright © 2018年 upmer. All rights reserved.
//

import UIKit

class ExampleBridge: NatureBridge {
    var name = "Peter"
    
    @objc func sysPlatform() -> String {
        debugPrint("sysPlatform")
        return "{\"a\":1}"
    }
    
    
    @objc func openView(_ type: String, _ jsonToString: String) {
        debugPrint(type)
        debugPrint(jsonToString)
    }
    
    @objc func call(_ phone: String) {
        debugPrint("phone ==== \(phone)")
    }
}

class Person: NSObject {
    var name = "Peter"
    
    
    func sysPlatform() -> String {
        debugPrint("sysPlatform")
        return "{\"a\":1}"
    }
    
    func openView(_ type: String, _ jsonToString: String) {
        debugPrint(type)
        debugPrint(jsonToString)
    }
    
    func call(_ phone: String) {
        debugPrint("phone ==== \(phone)")
    }
    
}
