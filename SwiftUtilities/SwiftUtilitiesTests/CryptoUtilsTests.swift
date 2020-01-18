//
//  CryptoUtilsTests.swift
//  SwiftUtilitiesTests
//
//  Created by HongXiangWen on 2020/1/18.
//  Copyright © 2020 WHX. All rights reserved.
//

import XCTest

class CryptoUtilsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHashString() {
        let testStr = "SwiftUtilities"
        XCTAssert(testStr.md5String == "c6e5aadbd452626584acb90ebc61a5cc")
        XCTAssert(testStr.sha1String == "4af76ce72b327781d8a909c86962c964eb7f38b5")
        XCTAssert(testStr.sha224String == "4905dad903088bb7382bfa26daef4350aa2b02800444c5ca22c030dd")
        XCTAssert(testStr.sha256String == "dfd454e54c0214dcf66a8c34cac6691ed64172fd22d1f49886eff03316dc0c45")
        XCTAssert(testStr.sha384String == "8b2a1d124a7f47a9eb305d1c52c4d7573e92afd2e654b8b70112cdf51d256aaa4c58eadb1b0a3794590e6b28238c5ff9")
        XCTAssert(testStr.sha512String == "09e5cbde4d8156e198e3d90c15e2b77045c44a02be3ea8c9ce2e49d1b4d8fd8149e1e201b8e7bd8bae50b22dabe40bafdf06797e5a1c457ed26c41287960d27a")
    }
    
    func testHmacString() {
        let testStr = "SwiftUtilities"
        let key = "hmacKey"
        XCTAssert(testStr.hmacString(.MD5, key: key) == "657422e73708d66629fa3203a81c7f8d")
        XCTAssert(testStr.hmacString(.SHA1, key: key) == "5526db7d6571892d62e894883fced28d7d7f33d1")
        XCTAssert(testStr.hmacString(.SHA224, key: key) == "190653a5eb9af2168c46a4bc5505246bdd42a936e6a3cedff5b32a44")
        XCTAssert(testStr.hmacString(.SHA256, key: key) == "dadf3b5cbc7e53b4a6d08b654966f41596c5f392f6efa51027564faafaa6cf9a")
        XCTAssert(testStr.hmacString(.SHA384, key: key) == "405fbec7cd0495528bff66a1e680b7788129d099bd1bc687a8330b612a4c0edef8fe781f9c53bc9279bce6b3582c8ddf")
        XCTAssert(testStr.hmacString(.SHA512, key: key) == "21627fd3086dbaadff448ac62aef9c606f0caa1a4c2703bed9e42a3f5df500da1ecf257a8d5e571fefaf12ad5967455ee1a7c63a07596769e34db8db10d4b052")
    }
    
}
