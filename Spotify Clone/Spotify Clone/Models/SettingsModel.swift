//
//  SettingsModel.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 17/09/2023.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
