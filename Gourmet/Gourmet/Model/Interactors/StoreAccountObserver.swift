//
//  StoreAccountObserver.swift
//  Gourmet
//
//  Created by David Martinez on 11/12/2016.
//  Copyright © 2016 Atenea. All rights reserved.
//

import Foundation

protocol StoreAccountObserverListener : NSObjectProtocol {
    
    func onChange(observer: StoreAccountObserver, account : Account?)
    
}

class StoreAccountObserver : NSObject {
    
    private weak var listener : StoreAccountObserverListener?
    
    func setListener (listener: StoreAccountObserverListener?) {
        self.listener = listener
    }
    
    func execute () {
        let defaults = UserDefaults.init(suiteName: "com.atenea.gourmet.appgroup")
        defaults?.addObserver(self, forKeyPath: "account", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    deinit {
        let defaults = UserDefaults.init(suiteName: "com.atenea.gourmet.appgroup")
        defaults?.removeObserver(self, forKeyPath: "account")
    }
    
    override func observeValue (
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
        
        guard let accountKey = keyPath else { return }
        let userDefaults = object as? UserDefaults
        if let accountData = userDefaults?.data(forKey: accountKey) {
            let account = NSKeyedUnarchiver.unarchiveObject(with: accountData) as? Account
            listener?.onChange(observer: self, account: account)
        } else {
            listener?.onChange(observer: self, account: nil)
        }
    }
    
}