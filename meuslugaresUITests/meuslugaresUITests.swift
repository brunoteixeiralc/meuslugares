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
        
        let app = XCUIApplication()
        snapshot("Tela Principal")
        
        let goButton = app.buttons["Marcar minha localização"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: goButton, handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Location Dialog") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
    
        let qualAMinhaLocalizaOButton = app.buttons["Qual a minha localização?"]
        qualAMinhaLocalizaOButton.tap()
        app.tap()
        if(!app.buttons["Marcar minha localização"].exists){
            qualAMinhaLocalizaOButton.tap()
        }
//        waitForExpectations(timeout: 20, handler: nil)
        
//        snapshot("Localização Achada")
        
//        app.buttons["Marcar minha localização"].tap()
//        snapshot("Tela de Marcação")
//        let textView = app.tables.children(matching: .cell).element(boundBy: 0).children(matching: .textView).element
//        textView.tap()
//        textView.typeText("apple store")
//        app.navigationBars["Marcação"].buttons["Salvar"].tap()
        
        let tabBarsQuery = app.tabBars
        
        tabBarsQuery.buttons["Localizações"].tap()
        snapshot("Tela de Localizações")
        
        tabBarsQuery.buttons["Mapa"].tap()
        snapshot("Tela do Mapa")
        
        
    }
    
}
