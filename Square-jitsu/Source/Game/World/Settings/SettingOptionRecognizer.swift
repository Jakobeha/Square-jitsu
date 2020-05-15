//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SettingOptionRecognizer {
    var name: String { get }

    func chooseThisOptionToDecode(json: JSON) -> Bool
}
