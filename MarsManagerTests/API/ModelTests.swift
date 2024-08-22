//
//  ModelTests.swift
//  MarsManagerTests
//
//  Created by Andrei Makarych on 21/08/2024.
//

@testable import MarsManager
import XCTest

final class ModelTests: XCTestCase {
    
    struct DecodeModelTest<T: Decodable & Equatable> {
        let source: String
        let wantType: T.Type
        let want: T
    }

    func testDecode() throws {
        let tests = [
            DecodeModelTest(source: #"{"playUrl":"https://mars.xyz/path?id=42","createdAt":"2024-08-21T20:31:48.941754Z","expiresAt":"2024-08-31T20:31:48.933Z", "playersCount":2, "awaitsInput":true}"#,
                            wantType: Game.self,
                            want: Game(playUrl: URL(string: "https://mars.xyz/path?id=42")!,
                                       playersCount: 2,
                                       awaitsInput: true))
        ]
        
        for tt in tests {
            XCTAssertEqual(try JSONDecoder().decode(tt.wantType, from: tt.source.data(using: .utf8)!), tt.want)
        }
    }
}
