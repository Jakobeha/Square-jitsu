//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class EqualityIsIdentity: Equatable, Hashable {
    static func ==(lhs: EqualityIsIdentity, rhs: EqualityIsIdentity) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
