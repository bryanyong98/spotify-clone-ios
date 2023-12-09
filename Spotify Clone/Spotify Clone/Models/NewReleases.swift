//
//  NewReleases.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 25/11/2023.
//

import Foundation

struct NewReleases: Codable {
    let albums: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
