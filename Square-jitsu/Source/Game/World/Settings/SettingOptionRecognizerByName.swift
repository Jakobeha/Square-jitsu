//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct SettingOptionRecognizerByName: SettingOptionRecognizer {
    let name: String

    func chooseThisOptionToDecode(json: JSON) -> Bool {
        json.dictionary?["type"]?.string == name
    }

    init(_ name: String) {
        self.name = name
    }
}
