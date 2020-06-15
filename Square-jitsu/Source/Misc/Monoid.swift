//
// Created by Jakob Hain on 6/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// We use the haskell names for methods because specific [] and append / union are better
protocol Monoid {
    static var mempty: Self { get }
    func mappend(_ other: Self) -> Self
}

extension Array: Monoid {
    static var mempty: [Element] { [] }

    func mappend(_ other: [Element]) -> [Element] {
        var combined = self
        combined.append(contentsOf: other)
        return combined
    }
}

extension Set: Monoid {
    static var mempty: Set<Element> { [] }

    func mappend(_ other: Set<Element>) -> Set<Element> {
        union(other)
    }
}