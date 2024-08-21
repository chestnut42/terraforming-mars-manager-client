//
//  Service.swift
//  MarsManager
//
//  Created by Andrei Makarych on 13/08/2024.
//

import Foundation

struct MarsAPIService {
    let baseUrl: URL
    let token: String
    
    func login() async throws -> LoginResponse {
        guard let url = URL(string: "/manager/api/v1/login", relativeTo: baseUrl) else {
            throw APIError.undefined(message: "can't create a URL")
        }
        
        let bodyData = try JSONEncoder().encode(LoginRequest())
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await process(request: request, as: LoginResponse.self)
    }
    
    func getGames() async throws -> GetGamesResponse {
        guard let url = URL(string: "/manager/api/v1/me/games", relativeTo: baseUrl) else {
            throw APIError.undefined(message: "can't create a URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await process(request: request, as: GetGamesResponse.self)
    }
    
    func search(for term: String) async throws -> SearchResponse {
        guard let url = URL(string: "/manager/api/v1/search", relativeTo: baseUrl) else {
            throw APIError.undefined(message: "can't create a URL")
        }
        
        let bodyData = try JSONEncoder().encode(SearchRequest(search: term))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await process(request: request, as: SearchResponse.self)
    }
    
    func update(deviceToken: Data) async throws -> UpdateDeviceTokenResponse {
        guard let url = URL(string: "/manager/api/v1/me/device-token", relativeTo: baseUrl) else {
            throw APIError.undefined(message: "can't create a URL")
        }
        
        let bodyData = try JSONEncoder().encode(UpdateDeviceTokenRequest(deviceToken: deviceToken))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await process(request: request, as: UpdateDeviceTokenResponse.self)
    }
    
    func createGame(players: [String]) async throws -> CreateGameResponse {
        guard let url = URL(string: "/manager/api/v1/game", relativeTo: baseUrl) else {
            throw APIError.undefined(message: "can't create a URL")
        }
        
        let bodyData = try JSONEncoder().encode(CreateGameRequest(players: players))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await process(request: request, as: CreateGameResponse.self)
    }
    
    func process<T: Decodable>(request: URLRequest, as type: T.Type) async throws -> T {
        let (data, resp) = try await URLSession.shared.data(for: request)
        if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode != 200 {
            throw APIError.httpError(status: httpResp.statusCode, data: data)
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error {
            throw APIError.decode(data: data, cause: error)
        }
    }
}
