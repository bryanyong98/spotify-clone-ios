//
//  RecommendationsResponse.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 09/12/2023.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
