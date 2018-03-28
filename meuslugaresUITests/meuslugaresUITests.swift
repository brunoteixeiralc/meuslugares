//
//  meuslugaresUITests.swift
//  meuslugaresUITests
//
//  Created by Bruno Corrêa on 18/03/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import XCTest

class meuslugaresUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUI() {
        
        let qualAMinhaLocalizaOButton = XCUIApplication().buttons["Qual a minha localização?"]
        qualAMinhaLocalizaOButton.tap()
        sleep(10)
        let qualAMinhaLocalizaOPararButton = XCUIApplication().buttons["Parar"]
        qualAMinhaLocalizaOPararButton.tap()
        
    }
    
}
