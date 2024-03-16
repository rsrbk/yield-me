//
//  CircleRequestModels.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import Foundation

struct RegisterUserRequest: Codable {
    let userId: String
}

struct SessionTokenRequest: Codable {
    let userId: String
}

struct InitializeAccountRequest: Codable {
    let idempotencyKey: String = UUID().uuidString
    let userToken: String
    let blockchains: [String]
}

// MARK: - Response Models
struct SessionTokenResponse: Codable {
    struct Data: Codable {
        let userToken: String
        let encryptionKey: String
    }
    let data: Data
}

struct InitializeAccountResponse: Codable {
    struct Data: Codable {
        let challengeId: String
    }
    let data: Data
}

struct UserStatusResponse: Codable {
    struct Data: Codable {
        let id: String
        let status: String
        let createDate: String
        let pinStatus: String
        let pinDetails: PinDetails
        let securityQuestionStatus: String
        let securityQuestionDetails: SecurityQuestionDetails
    }
    struct PinDetails: Codable {
        let failedAttempts: Int
    }
    struct SecurityQuestionDetails: Codable {
        let failedAttempts: Int
    }
    let data: Data
}

struct WalletStatusResponse: Codable {
    struct Data: Codable {
        let wallets: [Wallet]
    }
    struct Wallet: Codable {
        let address: String
    }
    let data: Data
}
