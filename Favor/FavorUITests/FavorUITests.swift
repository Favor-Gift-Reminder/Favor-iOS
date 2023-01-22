//
//  FavorUITests.swift
//  FavorUITests
//
//  Created by 이창준 on 2023/01/20.
//

import XCTest

final class FavorUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func signUpExample() throws {
    // UI tests must launch the application that they test.

    let app = XCUIApplication()
    app.launch()
    
    app.buttons["신규 회원가입"].tap()
    
    app.textFields["이메일"].typeText("nomatterjun@gmail.com")
    app.buttons["Next:"].tap()
    
    app.secureTextFields["비밀번호"].typeText("1111@@gg")
    app.buttons["Next:"].tap()
    
    app.secureTextFields["비밀번호 확인"].typeText("1111@@gg")
    app.buttons["Done"].tap()

    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
