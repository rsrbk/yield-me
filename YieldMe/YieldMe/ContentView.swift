//
//  ContentView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import SwiftUI
import CircleProgrammableWalletSDK

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase

    private let networking = CircleNetworking()
    private let adapter = WalletSdkAdapter()
    
    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()
    
    @State var isLoading: Bool = false
    @State var walletAddress: String?
    
    @State private var isCommunityPassPresented = false
    
    let items: [ProtocolItem] = [
        ProtocolItem(name: "Protocol 1", apr: 5.6, securityScore: 2, balance: 1200.50, url: "https://example.com", shortDescription: "This is a short description of the protocol.", tvl: "500M", launchDate: "2021-04-20", blockchain: "Ethereum", whitepaperURL: "https://example.com/whitepaper"),
        ProtocolItem(name: "Protocol 1", apr: 5.6, securityScore: 3, balance: 1200.50, url: "https://example.com", shortDescription: "This is a short description of the protocol.", tvl: "500M", launchDate: "2021-04-20", blockchain: "Ethereum", whitepaperURL: "https://example.com/whitepaper"),
        ProtocolItem(name: "Protocol 1", apr: 5.6, securityScore: 4, balance: 1200.50, url: "https://example.com", shortDescription: "This is a short description of the protocol.", tvl: "500M", launchDate: "2021-04-20", blockchain: "Ethereum", whitepaperURL: "https://example.com/whitepaper")
                                            
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        Image("logo", bundle: nil)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("Your USDC will grow like mushrooms")
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                        Spacer()
                        
                        if let walletAddress = walletAddress {
                            Text("Your address: \(walletAddress)")
                                .multilineTextAlignment(.center)
                        } else {
                            Text("You have not signed in yet")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Button(action: initiateSignIn) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                } else {
                                    Text("Sign in / sign up")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .controlSize(.large)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            Spacer()
                            Button(action: { self.isCommunityPassPresented.toggle() }) {
                                Text("Buy CommunityPass")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .controlSize(.large)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                        
                    }
                }
                .listRowBackground(Color(hex: "#E3FFE3"))
                
                Section {
                    ForEach(items) { item in
                        NavigationLink(destination: ProtocolDetailView(protocolItem: item)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline) // Main title
                                    Text("APR: \(item.apr, specifier: "%.2f")%")
                                        .font(.subheadline) // Subtitle
                                        .foregroundColor(.secondary) // Subtle color for subtitle
                                    Text("Balance: $\(item.balance, specifier: "%.2f")")
                                        .font(.subheadline) // Balance
                                        .foregroundColor(.secondary) // Subtle color for balance
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    // Security score might be visualized with a conditional color or icon
                                    HStack(spacing: 2) {
                                        ForEach(0..<item.securityScore, id: \.self) { _ in
                                            Image(systemName: "lock.fill") // Example icon for security score
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Text("Rating: \(item.securityScore)/5")
                                        .font(.subheadline) // Security score on the right
                                }
                            }
                        }
                    }
                }
                
                
            }
            .onAppear {
                self.adapter.initSDK(endPoint: "https://enduser-sdk.circle.com/v1/w3s", appId: "d4b087ec-88a2-582f-abcf-51eba61f8237")
            }
            .navigationTitle("Yield.me")
            .sheet(isPresented: $isCommunityPassPresented) {
                PremiumPassView()
            }
            //.navigationBarTitleDisplayMode(.inline)
            //.navigationDestination(for: ProtocolDetailView.self, destination: ProtocolItem.init)
        }
    }
    
    private func initiateSignIn() {
        isLoading = true
        Task.detached {
            let challenge = await self.networking.getSignInChallenge()
            await signIn(with: challenge)
        }
    }
    
    @MainActor func signIn(with challenge: CircleChallenge) {
        executeChallenge(challenge: challenge)
    }
    
    private func queryWalletStatus(challenge: CircleChallenge) async {
        // Get the wallet address
        while true {
            let status = await self.networking.getWalletStatus(userToken: challenge.userToken)
            if let address = status?.data.wallets.first?.address {
                isLoading = false
                walletAddress = address
                break
            }
        }
    }
}

extension ContentView {

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
                showToast(.success, message: "\(challeangeType) - \(challengeStatus)\(warningString)")

                response.onErrorController?.dismiss(animated: true)
                
                Task.detached {
                    await queryWalletStatus(challenge: challenge)
                }

            case .failure(let error):
                showToast(.failure, message: "Error: " + error.displayString)
                errorHandler(apiError: error, onErrorController: response.onErrorController)

                if error.errorCode == .userCanceled {
                    showChallengeResult = false
                }
            }

            if let onWarning = response.onWarning {
                print(onWarning)
            }
        }
    }

    func biometricsPIN(userToken: String, encryptionKey: String) {
        guard !userToken.isEmpty else { showToast(.general, message: "User Token is Empty"); return }
        guard !encryptionKey.isEmpty else { showToast(.general, message: "Encryption Key is Empty"); return }

        WalletSdk.shared.setBiometricsPin(userToken: userToken, encryptionKey: encryptionKey) {
            response in
            switch response.result {
            case .success(let result):
                let challengeStatus = result.status.rawValue
                let challeangeType = result.resultType.rawValue
                showToast(.success, message: "\(challeangeType) - \(challengeStatus)")

            case .failure(let error):
                showToast(.failure, message: "Error: " + error.displayString)
                errorHandler(apiError: error, onErrorController: response.onErrorController)
            }
        }
    }

    func errorHandler(apiError: ApiError, onErrorController: UINavigationController?) {
        switch apiError.errorCode {
        case .userHasSetPin,
             .biometricsSettingNotEnabled,
             .deviceNotSupportBiometrics,
             .biometricsKeyPermanentlyInvalidated,
             .biometricsUserSkip,
             .biometricsUserDisableForPin,
             .biometricsUserLockout,
             .biometricsUserLockoutPermanent,
             .biometricsUserNotAllowPermission,
             .biometricsInternalError:
            onErrorController?.dismiss(animated: true)
        default:
            break
        }
    }

    func newPIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_new_pin"])
    }

    func enterPIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_enter_pin"])
    }

    func changePIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_change_pin"])
    }

    func restorePIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_restore_pin"])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    ContentView()
}
