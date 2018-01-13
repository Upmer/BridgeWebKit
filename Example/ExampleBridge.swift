//
//  ExampleBridge.swift
//  BridgeWebKit
//
//  Created by Tsuf on 2018/1/5.
//  Copyright © 2018年 upmer. All rights reserved.
//

import UIKit
import AddressBook

class ExampleBridge: NatureBridge {
    
    @objc func showAlert() {
        debugPrint("show alert")
    }
    
    @objc func sysPlatform() -> String {
        debugPrint("sysPlatform")
        return "{\"a\":1, \"time\": \(Date().timeIntervalSince1970)}"
        
    }


    @objc func openView(_ type: String, _ jsonToString: String) {
        debugPrint(type)
        debugPrint(jsonToString)
    }

    @objc func call(_ phone: String) {
        debugPrint("phone ==== \(phone)")
    }
    
    @objc func postContacts(_ funcName: String!) {
        let callback = { (status: Int) -> (Void) in
            let js = funcName + "(\(status))"
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .denied || status == .restricted {
            //通讯录强制授权
            
            callback(0)
            return
        }
        
        var error: Unmanaged<CFError>?
        guard let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue() else {
            //      debugPrint(error?.takeRetainedValue())
            callback(0)
            return
        }
        
        ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
            DispatchQueue.main.async {
                if !granted {
                    callback(0)
                    return
                }
                var dict = [[String: String]]()
                if let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() {
                    let numberOfPeople = CFArrayGetCount(people)
                    for i in 0..<numberOfPeople {
                        var personDic = [String: String]()
                        
                        let personP = CFArrayGetValueAtIndex(people, i)
                        let person = unsafeBitCast(personP, to: ABRecord.self)
                        let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String ?? ""
                        let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String ?? ""
                        personDic["name"] = firstName + lastName
                        
                        // 电话
                        let phone = unsafeBitCast(ABRecordCopyValue(person, kABPersonPhoneProperty), to: ABMultiValue.self)
                        
                        if ABMultiValueGetCount(phone) > 0 {
                            let personPhone = unsafeBitCast(ABMultiValueCopyValueAtIndex(phone, 0), to: AnyObject.self) as? String ?? ""
                            personDic["phone"] = personPhone.replacingOccurrences(of: "-", with: "")
                            
                        } else {
                            continue
                        }
                        dict.append(personDic)
                    }
                    
                    if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
                        
                        let strJson = String(data: data, encoding: String.Encoding.utf8) ?? ""
                        
                        debugPrint(strJson)
                        callback(1)
                    } else {
                        callback(0)
                    }
                    
                } else {
                    callback(0)
                }
            }
        }
    }
}
