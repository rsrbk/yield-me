//
//  UserDefaultsManager.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let uuidKey = "uuid"
    private let addressKey = "address"
    private let walletIDKey = "wallet_id"
    private let userTokenKey = "user_token"
    private let encryptionKeyKey = "encryption_key"
    private let purchasedPassKey = "purchased_pass"

    var uuid: String {
        get {
            if let res = UserDefaults.standard.string(forKey: uuidKey) {
                return res
            } else {
                let newV = UUID().uuidString
                UserDefaults.standard.set(newV, forKey: uuidKey)
                return newV
            }
        }
    }
    
    var purchasedPass: Bool {
        get {
            UserDefaults.standard.bool(forKey: purchasedPassKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: purchasedPassKey)
        }
    }
    
    var encryptionKey: String? {
        get {
            UserDefaults.standard.string(forKey: encryptionKeyKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: encryptionKeyKey)
        }
    }
    
    var userToken: String? {
        get {
            UserDefaults.standard.string(forKey: userTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userTokenKey)
        }
    }
    
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
