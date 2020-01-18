//
//  HexUtilsTests.swift
//  SwiftUtilitiesTests
//
//  Created by HongXiangWen on 2020/1/18.
//  Copyright © 2020 WHX. All rights reserved.
//

import XCTest
@testable import SwiftUtilities

class HexUtilsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBytesConvert() {
        let uInt16: UInt16 = 0x1234
        XCTAssert(uInt16.littleEndianBytes == [0x34, 0x12])
        XCTAssert(uInt16.bigEndianBytes == [0x12, 0x34])
        
        let uInt32: UInt32 = 0x12345678
        XCTAssert(uInt32.littleEndianBytes == [0x78, 0x56, 0x34, 0x12])
        XCTAssert(uInt32.bigEndianBytes == [0x12, 0x34, 0x56, 0x78])

        let uInt64: UInt64 = 0x123456789ABCDEFF
        XCTAssert(uInt64.littleEndianBytes == [0xFF, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12])
        XCTAssert(uInt64.bigEndianBytes == [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xFF])
    }
    
    func testHexConvert() {
        let uInt16: UInt16 = 0x1234
        XCTAssert(uInt16.littleEndianBytes.hexString == "3412")
        XCTAssert(uInt16.bigEndianBytes.hexString == "1234")

        let uInt64: UInt64 = 0x123456789ABCDEFF
        let littleEndianData = Data(uInt64.littleEndianBytes)
        XCTAssert(littleEndianData.hexString == "ffdebc9a78563412")
        
        let bigEndianData = Data(uInt64.bigEndianBytes)
        XCTAssert(bigEndianData.hexDump() == "12 34 56 78 9A BC DE FF")
        
        let data = Data([0xAB, 0xBC, 0xCD, 0xDE])
        XCTAssert(data.hexDump(separator: "-", uppercase: false) == "ab-bc-cd-de")
    }
    
}
