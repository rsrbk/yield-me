//
//  UserDefaultsManager.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let uuidKey = "uniqueUUID"

    var uuid: String {
        get {
            // Try to get an existing UUID from UserDefaults
            if let uuid = UserDefaults.standard.string(forKey: uuidKey) {
                return uuid
            } else {
                // If not found, generate a new UUID, save it, and then return it
                let newUUID = UUID().uuidString
                UserDefaults.standard.set(newUUID, forKey: uuidKey)
                return newUUID
            }
        }
    }

    private init() {} // Private initialization to ensure singleton instance
}
