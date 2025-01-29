//
//  Model.swift
//  MarsManager
//
//  Created by Andrei Makarych on 13/08/2024.
//

import Foundation
import UIKit

enum Color: String, Codable, CaseIterable {
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

enum GameStatus: String, Codable, CaseIterable {
    case inProgress = "GAME_STATUS_IN_PROGRESS"
    case awaitsInput = "GAME_STATUS_AWAITS_INPUT"
    case finished = "GAME_STATUS_FINISHED"
}

enum Board: String, Codable, CaseIterable {
    case random = "RANDOM"
    case tharsis = "THARSIS"
    case hellas = "HELLAS"
    case elysium = "ELYSIUM"
}

struct User: Codable, Equatable {
    let id: String
    let nickname: String
    let color: Color
    let elo: Int
}

struct Game: Codable, Equatable {
    let playUrl: URL
    let playersCount: Int
    let status: GameStatus
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
    let board: Board
    let corporateEra: Bool
    let prelude: Bool
    let venusNext: Bool
    let solarPhase: Bool
    let colonies: Bool
}

struct CreateGameResponse: Codable, Equatable {}

struct UpdateDeviceTokenRequest: Codable, Equatable {
    let deviceToken: Data
}

struct UpdateDeviceTokenResponse: Codable, Equatable {}

struct GetMeResponse: Codable, Equatable {
    let user: User
}

struct UpdateMeRequest: Codable, Equatable {
    let nickname: String
    let color: Color
}

struct UpdateMeResponse: Codable, Equatable {
    let user: User
}

struct GetLeaderboardResponse: Codable, Equatable {
    let users: [User]
}
