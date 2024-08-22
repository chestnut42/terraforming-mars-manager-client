//
//  MarsManagerTests.swift
//  MarsManagerTests
//
//  Created by Andrei Makarych on 14/08/2024.
//

@testable import MarsManager
import XCTest

final class ErrorsTests: XCTestCase {
    
    struct LocalizeddescriptionTest {
        let error: Error
        let want: String
    }

    func testLocalizedDescription() throws {
        let tests = [
            LocalizeddescriptionTest(
                error: APIError.undefined(message: "some message"),
                want: "undefined error: some message"
            ),
            LocalizeddescriptionTest(
                error: APIError.decode(data: "data to decode".data(using: .utf8)!,
                                       cause: APIError.undefined(message: "the cause")),
                want: "can't decode: data to decode: undefined error: the cause"
            ),
            LocalizeddescriptionTest(
                error: APIError.httpError(status: 400, data: "some data".data(using: .utf8)!),
                want: "http error (400): some data")
        ]
        
        for tt in tests {
            XCTAssertEqual(tt.want, tt.error.localizedDescription)
        }
    }
}
