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
    private let google: GoogleSignInProvider?

    init() {
        let client = SupabaseProvider.client
        google = SupabaseProvider.config.googleClientID.map(GoogleSignInProvider.init(clientID:))
        authRepository = SupabaseAuthRepository(
            client: client,
            webAppURL: SupabaseProvider.config.webAppURL,
            google: google
        )
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
                .onOpenURL { google?.handle($0) }
        }
    }
}
