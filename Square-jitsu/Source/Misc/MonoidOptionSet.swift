//
// Created by Jakob Hain on 6/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol MonoidOptionSet: OptionSet, Monoid {}

extension MonoidOptionSet {
    static var mempty: Self { [] }

    func mappend(_ other: Self) -> Self {
        union(other)
    }
}
