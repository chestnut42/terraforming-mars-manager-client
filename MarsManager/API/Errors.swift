//
//  Errors.swift
//  MarsManager
//
//  Created by Andrei Makarych on 13/08/2024.
//

import Foundation

enum APIError: LocalizedError {
    case undefined(message: String)
    case decode(data: Data, cause: Error)
    case httpError(status: Int, data: Data)
    
    var errorDescription: String? {
        switch self {
        case .undefined(let message):
            return "undefined error: \(message)"
        case .decode(let data, let cause):
            let dataString = String(data: data, encoding: .utf8) ?? "<no string for data>"
            return "can't decode: \(dataString): \(cause.localizedDescription)"
        case .httpError(let status, let data):
            let dataString = String(data: data, encoding: .utf8) ?? "<no string for data>"
            return "http error (\(status)): \(dataString)"
        }
    }
}
