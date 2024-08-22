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

struct User: Codable, Equatable {
    let id: String
    let nickname: String
    let color: Color
}

struct Game: Codable, Equatable {
    let playUrl: URL
    let playersCount: Int
    let awaitsInput: Bool
}

struct LoginRequest: Codable, Equatable {}

struct LoginResponse: Codable, Equatable {
    let user: User
}

struct GetGamesResponse: Codable, Equatable {
    let games: [Game]
}

struct SearchRequest: Codable, Equatable {
    let search: String
}

struct SearchResponse: Codable, Equatable {
    let users: [User]
}

struct CreateGameRequest: Codable, Equatable {
    let players: [String]
}

struct CreateGameResponse: Codable, Equatable {}

struct UpdateDeviceTokenRequest: Codable, Equatable {
    let deviceToken: Data
}

struct UpdateDeviceTokenResponse: Codable, Equatable {}
