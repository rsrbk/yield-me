//
//  UserDefaultsManager.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let addressKey = "address"
    private let walletIDKey = "wallet_id"
    
    var walletAddress: String? {
        get {
            UserDefaults.standard.string(forKey: addressKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: addressKey)
        }
    }
    
    var walletID: String? {
        get {
            UserDefaults.standard.string(forKey: walletIDKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: walletIDKey)
        }
    }

    private init() {} // Private initialization to ensure singleton instance
}
