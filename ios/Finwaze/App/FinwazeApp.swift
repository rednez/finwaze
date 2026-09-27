//
//  FinwazeApp.swift
//  Finwaze
//
//  Created by Vasyl Yefimenko on 26.09.2026.
//

import SwiftUI

@main
struct FinwazeApp: App {
    private let authRepository: SupabaseAuthRepository
    private let app: AppViewModel

    init() {
        let client = SupabaseProvider.client
        authRepository = SupabaseAuthRepository(client: client, webAppURL: SupabaseProvider.config.webAppURL)
        app = AppViewModel(
            authRepository: authRepository,
            liveRepositories: .live(client: client),
            preferences: DevicePreferences(),
            demoMode: DemoModeStorage()
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(app: app, authRepository: authRepository)
        }
    }
}
