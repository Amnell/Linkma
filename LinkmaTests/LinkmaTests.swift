//
//  LinkmaTests.swift
//  LinkmaTests
//
//  Created by Mathias Amnell on 2023-08-07.
//

import XCTest
@testable import Linkma

final class LinkmaTests: XCTestCase {

    func testExample() throws {
        do {
            let something = try "1, 2".replacingGroups(matching: try Regex(#"(\d+), (\d+)"#), with: "$2, $1")
            XCTAssertEqual(something, "2, 1")
        }

        do {
            let something = try "1, 2, 3, 4, 5, 6, 7, 8, 9".replacingGroups(matching: try Regex(#"(\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+)"#), with: "$9, $8, $7, $6, $5, $4, $3, $2, $1")
            XCTAssertEqual(something, "9, 8, 7, 6, 5, 4, 3, 2, 1")
        }

        do {
            let something = try "1, 2, 3, 4, 5, 6, 7, 8, 9, 10".replacingGroups(matching: try Regex(#"(\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+)"#), with: "$10, $9, $8, $7, $6, $5, $4, $3, $2, $1")
            XCTAssertEqual(something, "10, 9, 8, 7, 6, 5, 4, 3, 2, 1")
        }

        do {
            let something = try "IMAG-123".replacingGroups(matching: try Regex(#"^(IMAG-\d+)"#), with: "http://google.com/?q=$1")
            XCTAssertEqual(something, "http://google.com/?q=IMAG-123")
        }

        do {
            let something = try "IMAG-123".replacingGroups(matching: try Regex(#"^IMAG-\d+"#), with: "http://google.com/?q=$0")
            XCTAssertEqual(something, "http://google.com/?q=IMAG-123")
        }

        do {
            let something = try "IMAG-123".replacingGroups(matching: try Regex(#"^IMAG-(\d+)"#), with: "http://google.com/?q=$0-$1")
            XCTAssertEqual(something, "http://google.com/?q=IMAG-123-123")
        }

        do {
            let something = try "IMAG-123".replacingGroups(matching: try Regex("^IMAG-\\d+"), with: "http://google.com/?q=$0")
            XCTAssertEqual(something, "http://google.com/?q=IMAG-123")
        }

        do {
            let something = try "IMAG-123".replacingGroups(matching: try Regex(#"IMAG-\d+"#), with: "https://ikano-bank.atlassian.net/browse/$0")
            XCTAssertEqual(something, "https://ikano-bank.atlassian.net/browse/IMAG-123")
        }
    }
}
