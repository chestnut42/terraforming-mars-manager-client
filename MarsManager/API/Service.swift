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
            throw APIError.unknown(message: "can't create a URL")
        }
        
        let bodyData = try JSONEncoder().encode(LoginRequest())
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        } catch let error {
            throw APIError.responseDecode(data: data, cause: error)
        }
    }
}
