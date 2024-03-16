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
    let accountType: String
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
        let id: String
        let address: String
    }
    let data: Data
}

struct WalletBalanceResponse: Codable {
    struct Data: Codable {
        let tokenBalances: [TokenBalance]
    }
    struct TokenBalance: Codable {
        struct Token: Codable {
            let symbol: String
        }
        let token: Token
        let amount: String
    }
    let data: Data
}

struct ContractExecutionChallengeRequest: Codable {
    let idempotencyKey: String
    let abiFunctionSignature: String?
    let abiParameters: [String]?
    let callData: String?
    let amount: String?
    let contractAddress: String
    let feeLevel: String?
    let gasLimit: String?
    let gasPrice: String?
    let maxFee: String?
    let priorityFee: String?
    let refId: String?
    let walletId: String
    
    init(
        idempotencyKey: String,
        abiFunctionSignature: String,
        abiParameters: [String],
        contractAddress: String,
//        gasPrice: String,
//        gasLimit: String,
//        priorityFee: String,
//        maxFee: String,
        walletId: String)
    {
            self.idempotencyKey = idempotencyKey
            self.abiFunctionSignature = abiFunctionSignature
            self.abiParameters = abiParameters
            self.contractAddress = contractAddress
            self.walletId = walletId
            
            // Setting the rest of the parameters to nil
            self.callData = nil
            self.amount = nil
            self.feeLevel = "MEDIUM"
            self.gasLimit = "100000"
            self.gasPrice = nil
            self.maxFee = "5.935224468"
            self.priorityFee = "1.022783914"
            self.refId = nil
        }
}

struct ContractExecutionChallengeResponse: Codable {
    struct Data: Codable {
        let challengeId: String
    }
    let data: Data
}
