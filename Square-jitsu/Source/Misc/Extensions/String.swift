//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension String {
    func leftPadding(toLength newLength: Int, withPad character: Character) -> String {
        String(repeatElement(character, count: newLength - self.count)) + self
    }

    func strip(prefix: String) -> Substring? {
        starts(with: prefix) ? self[index(startIndex, offsetBy: prefix.count)...] : nil
    }
}
