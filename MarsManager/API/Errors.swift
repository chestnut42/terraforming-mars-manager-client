//
//  Errors.swift
//  MarsManager
//
//  Created by Andrei Makarych on 13/08/2024.
//

import Foundation

enum APIError: Error {
    case unknown(message: String)
    case responseDecode(data: Data, cause: Error)
}
