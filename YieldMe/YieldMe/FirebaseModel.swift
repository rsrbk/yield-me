//
//  FirebaseModel.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 16/03/2024.
//

import Foundation

// Dummy data structure for ProtocolItem, replace with your actual data model
struct ProtocolItem: Identifiable, Hashable, Codable {
    var id: Int
    
    var name: String
    var apr: Double
    var rating: Int
    var url: String
    var shortDescription: String
    var tvl: String
    var launchDate: String
    var network: String
    var whitepaper: String
}
