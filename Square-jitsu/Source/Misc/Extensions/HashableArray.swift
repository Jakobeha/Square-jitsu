//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    var hasDuplicates: Bool {
        Set(self).count != count
    }
}
