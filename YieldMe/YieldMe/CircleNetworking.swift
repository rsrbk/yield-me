//
//  CircleNetworking.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import Foundation

class CircleNetworking {
    
    let apiKey = "TEST_API_KEY:f6155880d9b1b9912a1a441b4a5442ad:34423e3e3b3cae0aa46eac5ba583d01c"
    let baseUrl = "https://enduser-sdk.circle.com/v1/w3s"
    let jsonContentType = "application/json"
    
    private func createRequest(url: URL, method: String, apiKey: String, userToken: String? = nil, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(jsonContentType, forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if let userToken = userToken {
            request.setValue(userToken, forHTTPHeaderField: "X-User-Token")
        }
        request.httpBody = body
        return request
    }
    
    func getSignInChallenge() async -> CircleChallenge {
        let userId = User.shared.uuid
        
        let _ = await registerUser(userId: userId)
        let sessionToken = await getSessionToken(userId: userId)
        let account = await initializeAccount(userToken: sessionToken!.data.userToken, blockchains: ["MATIC-MUMBAI"])
        
        User.shared.sessionToken = sessionToken
        
        return CircleChallenge(
            userToken: sessionToken!.data.userToken,
            encryptionKey: sessionToken!.data.encryptionKey,
            challengeId: account!.data.challengeId)
    }
    
    func registerUser(userId: String) async {
        guard let url = URL(string: "\(baseUrl)/users"),
              let encodedBody = try? JSONEncoder().encode(RegisterUserRequest(userId: userId)) else { return }
        
        let request = createRequest(url: url, method: "POST", apiKey: apiKey, body: encodedBody)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 201 else {
                print("Failed to register user")
                return
            }
            print("User registered successfully")
        } catch {
            print("Error registering user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get Session Token
    func getSessionToken(userId: String) async -> SessionTokenResponse? {
        guard let url = URL(string: "\(baseUrl)/users/token"),
              let encodedBody = try? JSONEncoder().encode(SessionTokenRequest(userId: userId)) else { return nil }
        
        let request = createRequest(url: url, method: "POST", apiKey: apiKey, body: encodedBody)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(SessionTokenResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error getting session token: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Initialize Account
    func initializeAccount(userToken: String, blockchains: [String]) async -> InitializeAccountResponse? {
        guard let url = URL(string: "\(baseUrl)/user/initialize"),
              let encodedBody = try? JSONEncoder().encode(InitializeAccountRequest(userToken: userToken, accountType: "SCA", blockchains: blockchains)) else { return nil }
        
        let request = createRequest(url: url, method: "POST", apiKey: apiKey, userToken: userToken, body: encodedBody)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(InitializeAccountResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error initializing account: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Get User Status
    func getUserStatus(userToken: String) async -> UserStatusResponse? {
        guard let url = URL(string: "\(baseUrl)/user") else { return nil }
        
        let request = createRequest(url: url, method: "GET", apiKey: apiKey, userToken: userToken)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(UserStatusResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error getting user status: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Get Wallet Status
    func getWalletStatus(userToken: String) async -> WalletStatusResponse? {
        guard let url = URL(string: "\(baseUrl)/wallets") else { return nil }
        
        let request = createRequest(url: url, method: "GET", apiKey: apiKey, userToken: userToken)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(WalletStatusResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error getting wallet status: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Get Wallet Balance
    func getWalletBalance(userToken: String, walletID: String) async -> WalletBalanceResponse? {
        guard let url = URL(string: "\(baseUrl)/wallets/\(walletID)/balances") else { return nil }

        let request = createRequest(url: url, method: "GET", apiKey: apiKey)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(WalletBalanceResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error getting wallet status: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Create User Transaction Contract Execution Challenge
    func createContractExecutionChallenge(requestModel: ContractExecutionChallengeRequest) async -> ContractExecutionChallengeResponse? {
        guard let url = URL(string: "\(baseUrl)/user/transactions/contractExecution") else { return nil }
        
        guard let encodedBody = try? JSONEncoder().encode(requestModel) else {
            print("Failed to encode request model")
            return nil
        }
        
        let request = createRequest(url: url, method: "POST", apiKey: apiKey, userToken: User.shared.sessionToken!.data.userToken, body: encodedBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Request failed with response: \(response)")
                return nil
            }
            let decodedResponse = try JSONDecoder().decode(ContractExecutionChallengeResponse.self, from: data)
            return decodedResponse
        } catch {
            print("Error creating contract execution challenge: \(error.localizedDescription)")
            return nil
        }
    }
}
