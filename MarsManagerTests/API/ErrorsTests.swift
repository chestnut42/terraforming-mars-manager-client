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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
            )
        ]
        
        for tt in tests {
            XCTAssertEqual(tt.want, tt.error.localizedDescription)
        }
    }
}
