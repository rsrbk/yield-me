//
//  PremiumPassView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 16/03/2024.
//

import SwiftUI
import CircleProgrammableWalletSDK

struct PremiumPassView: View {
    @State private var isStepOneCompleted: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL
    @State var isLoadingWorldCoin: Bool = false
    
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
                        
                        Button(action: {
                            // Implement the purchase functionality here
                            Task.detached {
                                await self.initiatePassMint()
                            }
                        }) {
                            Text("Purchase for $10")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Premium Pass")
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
    
    private func initiatePassMint() async {
        let request = ContractExecutionChallengeRequest(
            idempotencyKey: UUID().uuidString,
            abiFunctionSignature: "function buyPass( address passReceiver, uint256 paymentPeriod, uint256 root, uint256 nullifierHash, uint256[8] calldata proof ) public returns (uint256)",
            abiParameters: [
                User.shared.address!,
                "1",
                proof!.merkle_root.toString(),
                proof!.nullifier_hash.toString(),
                proof!.proof.toString()
            ],
            contractAddress: "0x938545C68Ed97E993aFFcF306aF33d08f2525A78",
            walletId: User.shared.walletID!)
        let response = await CircleNetworking().createContractExecutionChallenge(requestModel: request)
        
        let challenge = CircleChallenge(userToken: User.shared.sessionToken!.data.userToken, encryptionKey: User.shared.sessionToken!.data.encryptionKey, challengeId: response!.data.challengeId)
        executeChallenge(challenge: challenge)
    }
    
    func executeChallenge(challenge: CircleChallenge) {
        var showChallengeResult = true

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

                response.onErrorController?.dismiss(animated: true)

            case .failure(let error):
                if error.errorCode == .userCanceled {
                    showChallengeResult = false
                }
            }

            if let onWarning = response.onWarning {
                print(onWarning)
            }
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
