//
//  ProtocolDetailView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import SwiftUI

struct ProtocolDetailView: View {
    var protocolItem: ProtocolItem // Assume ProtocolItem includes all necessary details
    @State private var newCommentText: String = ""
    @State private var likesCount: Int = Int.random(in: 0...10)
    @State private var dislikesCount: Int = Int.random(in: 0...10)
    
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
                if protocolItem.comments.isEmpty {
                    Text("No comments yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(protocolItem.comments, id: \.id) { comment in
                        CommentView(comment: comment)
                    }
                }
                
                HStack {
                    TextField("Add a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Actions to add the comment
                        // Add the new comment to the list of comments
                        // You would implement the logic to append the new comment here
                        // For example, you might call a function to post the comment to your server or database
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
        .navigationTitle(protocolItem.name)
    }
}

// Mock model extension to include additional details and comments
extension ProtocolItem {
    var comments: [Comment] {
        [
            Comment(id: 1, name: "Alice", profilePicture: "placeholder", time: Date(), text: "Great protocol!"),
            Comment(id: 2, name: "Bob", profilePicture: "placeholder", time: Date().addingTimeInterval(-3600), text: "Looking forward to the new features."),
            // Add more mock comments as needed
        ]
    }
}

struct Comment: Identifiable {
    let id: Int
    let name: String
    let profilePicture: String
    let time: Date
    let text: String
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
                    Text(comment.name)
                        .font(.headline)
                    Spacer()
                    Text(comment.time, style: .time)
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
