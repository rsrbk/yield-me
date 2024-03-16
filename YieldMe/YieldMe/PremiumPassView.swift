//
//  PremiumPassView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 16/03/2024.
//

import SwiftUI
import CircleProgrammableWalletSDK
import BigInt

struct PremiumPassView: View {
    @State private var isStepOneCompleted: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL
    
    @State var isLoadingWorldCoin: Bool = false
    @State var isLoadingMint: Bool = false

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()
    
    @State private var proof: WrappedProof?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Spacer() // Pushes the button to the right
                    Button("Close") {
                        // Dismiss the sheet
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                }
                
                // Logo with rounded corners and light grey margins
                Image("community_pass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
                    .padding()
                    .cornerRadius(20)
                    .padding([.leading, .trailing], 20)
                
                Text("Unlock all premium features with the Community Pass. Enjoy exclusive access to new functionalities and priority support.")
                    .font(.headline)
                    .padding()
                
                // List of features with infographics
                VStack(alignment: .leading, spacing: 8) {
                    FeatureView(emoji: "📖", text: "Read other people's reviews on yield protocols")
                    FeatureView(emoji: "✍️", text: "Write your own reviews")
                    FeatureView(emoji: "👍", text: "Upvote or downvote reviews")
                    FeatureView(emoji: "💸", text: "Own a share of revenue from the Community Pass if your reviews are popular")
                }
                
                // Step 1
                VStack(alignment: .leading, spacing: 10) {
                    Text("Step 1: Sign in with WorldCoin 🪙")
                        .font(.title2)
                        .bold()
                    
                    Text("This step is necessary to verify that you are actually a human.")
                        .font(.body)
                    
                    if isStepOneCompleted {
                        HStack {
                            Text("Success")
                                .bold()
                                .foregroundColor(.green)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        Button(action: {
                            // Implement the sign-in functionality here
                            self.isLoadingWorldCoin = true
                            Task.detached {
                                self.initiateWorldCoin()
                            }
                        }) {
                            Text("Sign in with WorldCoin")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                // Step 2
                if isStepOneCompleted {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Step 2: Purchase the Pass")
                            .font(.title2)
                            .bold()
                        
                        Text("Get your Premium Pass now for just $10 and start enjoying all the benefits.")
                            .font(.body)
                        
                        Button(action: initiatePassMint) {
                            if isLoadingMint {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            } else {
                                Text("Purchase for $10")
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding(.horizontal, 20)
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }
    
    private func initiateWorldCoin() {
        let session = WrappedSession("app_14d0217a5ec381effeb27d036b7c6c63", "rust-test")
        let url = session.get_url().toString()
        openURL(URL(string: url)!)
        
        while true {
            let res = session.poll()
            switch res {
            case .Confirmed(let proof):
                self.proof = proof
                isLoadingWorldCoin = false
                isStepOneCompleted = true
                print(proof.proof.toString())
                break
            default:
                continue
            }
        }
    }
    
    private func initiatePassMint() {
        isLoadingMint = true
        Task.detached {
            let networking = CircleNetworking()

            let request = ContractExecutionChallengeRequest(
                idempotencyKey: UUID().uuidString,
                abiFunctionSignature: "buyPass(address, uint256, uint256, uint256, bytes calldata)",
                abiParameters: [
                    UserDefaultsManager.shared.walletAddress!,
                    "1",
                    hexStringToDecimalString(proof!.merkle_root.toString())!,
                    hexStringToDecimalString(proof!.nullifier_hash.toString())!,//,
                    proof!.proof.toString()
                ],
                contractAddress: "0xaCe267a80E492f43aE30BccAF2f6049F4FcA05F7",
                walletId: UserDefaultsManager.shared.walletID!)
            let response = await CircleNetworking().createContractExecutionChallenge(requestModel: request)
            
            guard let userToken = UserDefaultsManager.shared.userToken else { return }
            guard let encryptionKey = UserDefaultsManager.shared.encryptionKey else { return }
            guard let challengeId = response?.data.challengeId else { return }
            let challenge = CircleChallenge(userToken: userToken, encryptionKey: encryptionKey, challengeId: challengeId)
            await executeChallenge(challenge: challenge)
        }
    }
    
    @MainActor func executeChallenge(challenge: CircleChallenge) {
        WalletSdk.shared.execute(userToken: challenge.userToken,
                                 encryptionKey: challenge.encryptionKey,
                                 challengeIds: [challenge.challengeId]) { response in
            switch response.result {
            case .success(let result):
                let challengeStatus = result.status.rawValue
                let challeangeType = result.resultType.rawValue
                let warningType = response.onWarning?.warningType
                let warningString = warningType != nil ?
                " (\(warningType!))" : ""
                
                UserDefaultsManager.shared.purchasedPass = true
                showToast(.success, message: "Community pass is purchased")

                response.onErrorController?.dismiss(animated: true)
                
            case .failure(let error):
                showToast(.failure, message: "Error: " + error.displayString)
            }

            if let onWarning = response.onWarning {
                print(onWarning)
            }
            
            isLoadingMint = false
            sleep(2)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    enum ToastType {
        case general
        case success
        case failure
    }

    func showToast(_ type: ToastType, message: String) {
        toastMessage = message
        showToast = true

        switch type {
        case .general:
            toastConfig = Toast.Config()
        case .success:
            toastConfig = Toast.Config(backgroundColor: .green, duration: 2.0)
        case .failure:
            toastConfig = Toast.Config(backgroundColor: .pink, duration: 10.0)
        }
    }
}

struct FeatureView: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack {
            Text(emoji)
            Text(text)
                .font(.body)
        }
    }
}

func hexStringToDecimalString(_ hexString: String) -> String? {
    // Remove the "0x" prefix if present
    let hex = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
    
    // Attempt to create a BigInt from the hexadecimal string
    guard let bigInt = BigInt(hex, radix: 16) else {
        return nil // Return nil if the string is not a valid hexadecimal number
    }
    
    // Convert the BigInt to a decimal string and return it
    return String(bigInt)
}
