//
//  Model.swift
//  MarsManager
//
//  Created by Andrei Makarych on 13/08/2024.
//

import Foundation

enum Color: String, Codable {
    case blue = "BLUE"
    case red = "RED"
    case yellow = "YELLOW"
    case green = "GREEN"
    case black = "BLACK"
    case purple = "PURPLE"
    case orange = "ORANGE"
    case pink = "PINK"
    case bronze = "BRONZE"
}

struct User: Codable {
    let id: String
    let nickname: String
    let color: Color
}

struct Game: Codable {
    let playURL: URL
    let playersCount: Int
    let awaitsInput: Bool
}

struct LoginRequest: Codable {}

struct LoginResponse: Codable {
    let user: User
}

struct GetGamesResponse: Codable {
    let games: [Game]
}

struct SearchRequest: Codable {
    let search: String
}

struct SearchResponse: Codable {
    let users: [User]
}

struct CreateGameRequest: Codable {
    let players: [String]
}

struct CreateGameResponse: Codable {}

struct UpdateDeviceTokenRequest: Codable {
    let deviceToken: Data
}

struct UpdateDeviceTokenResponse: Codable {}
