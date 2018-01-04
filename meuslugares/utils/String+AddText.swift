//
//  String+AddText.swift
//  meuslugares
//
//  Created by Bruno Lemgruber on 04/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text: String?,separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text }
    }
}
