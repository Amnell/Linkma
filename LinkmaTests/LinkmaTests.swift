//
//  LinkmaTests.swift
//  LinkmaTests
//
//  Created by Mathias Amnell on 2023-08-07.
//

import XCTest
@testable import Linkma

final class LinkmaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let regexString: String = "POTATO-\\d"
        let regex = try! Regex(regexString)
        let matches = "POTATO-123".matches(of: regex)
        XCTAssertEqual(matches.count, 1)
        matches.forEach { match in
            print(match)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
