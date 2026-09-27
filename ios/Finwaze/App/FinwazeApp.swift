//
//  FinwazeApp.swift
//  Finwaze
//
//  Created by Vasyl Yefimenko on 26.09.2026.
//

import SwiftUI

@main
struct FinwazeApp: App {
    private let authRepository = SupabaseAuthRepository(client: SupabaseProvider.client)

    var body: some Scene {
        WindowGroup {
            RootView(authRepository: authRepository)
        }
    }
}
