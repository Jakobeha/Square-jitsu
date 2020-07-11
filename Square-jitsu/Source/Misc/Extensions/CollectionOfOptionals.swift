//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Collection where Element: OptionalCastable {
    var compacted: [Element.Wrapped] {
        compactMap { element in
            element.toOptional
        }
    }
}