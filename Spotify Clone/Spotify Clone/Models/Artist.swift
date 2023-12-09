//
//  Artist.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
