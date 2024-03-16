//
//  FirebaseNetworking.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 16/03/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseNetworking {
    private var db = Firestore.firestore()
    
    func fetchProtocols() async -> [ProtocolItem] {
        let querySnapshot = try! await db.collection("projects").getDocuments()
        for document in querySnapshot.documents {
            print("\(document.documentID) => \(document.data())")
          }
        
        return querySnapshot.documents.compactMap { document -> ProtocolItem? in
            try? document.data(as: ProtocolItem.self)
        }
    }
    
    func fetchComments(for id: Int) async -> [Comment] {
        let querySnapshot = try! await db.collection("comments")
            .whereField("projectId", isEqualTo: id)
            .getDocuments()
        
        return querySnapshot.documents.compactMap { document -> Comment? in
            try? document.data(as: Comment.self)
        }
    }
}
