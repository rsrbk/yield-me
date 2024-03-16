//
//  YieldMeApp.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 15/03/2024.
//

import SwiftUI
import FirebaseCore

@main
struct YieldMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

//
//class User {
//    static let shared = User()
//    let uuid = UUID().uuidString
//    var address: String?
//    var walletID: String?
//    
//    var sessionToken: SessionTokenResponse?
//}
