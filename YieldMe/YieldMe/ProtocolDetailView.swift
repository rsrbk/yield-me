//
//  ProtocolDetailView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import SwiftUI
import GaugeKit
import CircleProgrammableWalletSDK
import BigInt

struct ProtocolDetailView: View {
    var protocolItem: ProtocolItem // Assume ProtocolItem includes all necessary details
    @State private var newCommentText: String = ""
    @State private var likesCount: Int = Int.random(in: 0...10)
    @State private var dislikesCount: Int = Int.random(in: 0...10)
    @FocusState private var isInputFieldFocused: Bool // Step 1: Focus state
    
    @State private var comments: [Comment] = []
    
    @State private var depositAmount: String = ""
    @State private var isProcessingDeposit: Bool = false
    
    let firebaseNetworking = FirebaseNetworking()
    
    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    Image(protocolItem.name) // Your logo image name
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100) // Adjust the height as needed
                    Spacer()
                }
            }
            
            Section(header: Text("Details")) {
                HStack {
                    Text("Title")
                        .bold()
                    Spacer()
                    Text(protocolItem.name)
                }
                
                HStack {
                    Text("URL")
                        .bold()
                    Spacer()
                    Text(protocolItem.url)
                        .foregroundColor(.blue)
                }
                
                Text(protocolItem.shortDescription)
                
                HStack {
                    Text("TVL")
                        .bold()
                    Spacer()
                    Text(protocolItem.tvl)
                }
                
                HStack {
                    Text("Launch Date")
                        .bold()
                    Spacer()
                    Text(protocolItem.launchDate)
                }
                
                HStack {
                    Text("Blockchain")
                        .bold()
                    Spacer()
                    Text(protocolItem.network)
                }
                
                HStack {
                    Text("Whitepaper")
                        .bold()
                    Spacer()
                    Link("View", destination: URL(string: protocolItem.whitepaper)!)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Security Score")
                        .bold()
                    Spacer()
                    Text("\(protocolItem.rating) / 5")
                }
            }
            
            Section("Security score") {
                HStack {
                    Spacer()
                    GaugeView(title: "out of 100", value: protocolItem.rating * 20, colors: [.red, .orange, .yellow, .green])
                        .frame(height: 200, alignment: .center)
                    Spacer()
                }
            }
            
            Section(header: Text("Deposit Funds")) {
                TextField("Amount in USDC", text: $depositAmount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center) // Centers the text
                    .disabled(isProcessingDeposit) // Disable editing during processing
                
                HStack {
                    Spacer()
                    Button(action: depositFunds) {
                        if isProcessingDeposit {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.white)
                        } else {
                            Text("Deposit")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.large)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .disabled(depositAmount.isEmpty || isProcessingDeposit)
                    Spacer()
                }
            }
            
            if UserDefaultsManager.shared.purchasedPass {
                Section(header: Text("Like or Dislike")) {
                    HStack(spacing: 40) {
                        // Like Button
                        Button(action: {
                            // Logic to increment the likes count
                            likesCount += 1
                            // Implement logic for liking once or toggling like/dislike if needed
                        }) {
                            VStack {
                                Text("👍")
                                    .font(.largeTitle)
                                Text("\(likesCount)")
                                    .font(.title) // Bigger font size
                                    .foregroundColor(.black) // Black text color
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        
                        // Dislike Button
                        Button(action: {
                            // Logic to increment the dislikes count
                            dislikesCount += 1
                            // Implement logic for disliking once or toggling like/dislike if needed
                        }) {
                            VStack {
                                Text("👎")
                                    .font(.largeTitle)
                                Text("\(dislikesCount)")
                                    .font(.title) // Bigger font size
                                    .foregroundColor(.black) // Black text color
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .padding()
                }
                
                Section(header: Text("Comments")) {
                    if comments.isEmpty {
                        Text("No comments yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(comments) { comment in
                            CommentView(comment: comment)
                        }
                    }
                    
                    HStack {
                        TextField("Add a comment...", text: $newCommentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isInputFieldFocused) // Step 2: Bind focus state
                        
                        Button(action: {
                            let newId = (comments.max(by: { $0.id < $1.id })?.id ?? 0) + 1
                            let newComment = Comment(id: newId, user: truncateString(UserDefaultsManager.shared.walletAddress!, toMaxLength: 20), text: newCommentText)
                            comments.append(newComment)
                            newCommentText = "" // Reset the text field
                            isInputFieldFocused = false // Step 3: Dismiss the keyboard
                        }) {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(newCommentText.isEmpty)
                    }
                }
            }
            
        }
        .navigationTitle(protocolItem.name)
        .onAppear {
            Task.detached {
                self.comments = await firebaseNetworking.fetchComments(for: protocolItem.id)
            }
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }
    
    func depositFunds() {
        // Start the progress animation
        isProcessingDeposit = true
        
        Task.detached {
            print(depositAmount)
            let request = ContractExecutionChallengeRequest(
                idempotencyKey: UUID().uuidString,
                abiFunctionSignature: "depositIntoPool(uint256, uint256)",
                abiParameters: [
                    "\(protocolItem.id)",
                    "\(BigInt(depositAmount)! * BigInt(100000000000000000))"
                ],
                contractAddress: "0x17dE46BAB525309fE846f0eeD4A4dcBFBfB588d4",
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
            
            isProcessingDeposit = false
            showToast(.success, message: "Deposit successful!")
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

struct CommentView: View {
    var comment: Comment
    
    var body: some View {
        HStack(alignment: .top) {
            // Placeholder profile image
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                // Name and time
                HStack {
                    Text(comment.user)
                        .font(.headline)
                    Spacer()
                    Text(Date(), style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                // Comment text
                Text(comment.text)
            }
        }
        .padding(.vertical)
    }
}

struct CommentInputForm: View {
    @State private var commentText: String = ""
    
    var body: some View {
        VStack {
            TextField("Add a comment...", text: $commentText)
                .textFieldStyle(.roundedBorder)
            
            Button("Post") {
                // Logic to post the comment
            }
            .buttonStyle(.borderedProminent)
            .disabled(commentText.isEmpty)
        }
    }
}
