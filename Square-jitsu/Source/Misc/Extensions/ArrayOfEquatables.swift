//
// Created by Jakob Hain on 6/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeIfPresent(_ element: Element) {
        while let index = firstIndex(of: element) {
            remove(at: index)
        }
    }

    mutating func subtract<OtherCollection: Collection>(_ elements: OtherCollection) where OtherCollection.Element == Element {
        for element in elements {
            removeIfPresent(element)
        }
    }


    func subtracting<OtherCollection: Collection>(_ elements: OtherCollection) -> [Element] where OtherCollection.Element == Element {
        var result = self
        result.subtract(elements)
        return result
    }
}