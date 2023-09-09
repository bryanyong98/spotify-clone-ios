//
//  AuthManager.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()

    struct Constants {
        static let clientID = "88600196bc9c45609b4947359f6c0e7a"
        static let clientSecret = "924cff0de9c042dcb72fcd0f96465e5f"
    }

    private init() {}

    public var signInURL: URL? {
        let scopes = "user-read-private"
        let redirectURI = "https://www.iosacademy.io"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }

    var isSignedIn: Bool {
        return false
    }

    private var accessToken: String? {
        return nil
    }

    private var refreshToken: String? {
        return nil
    }

    private var tokenExpirationDate: Date? {
        return nil
    }

    private var shouldRefreshToken: Bool {
        return false
    }

    public func exchangeCodeForToken(
        code: String,
        completion: @escaping ((Bool) -> Void)
    ) {
        // Get token
    }

    private func refreshAccessToken() {
        
    }

    private func cacheToken() {
        
    }
}
