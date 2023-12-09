//
//  UserProfile.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}
