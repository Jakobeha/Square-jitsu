//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Set {
    func contains<OtherCollection: Collection>(anyOf other: OtherCollection) -> Bool where OtherCollection.Element == Element {
        other.contains(where: self.contains)
    }

    func contains<OtherCollection: Collection>(allOf other: OtherCollection) -> Bool where OtherCollection.Element == Element {
        other.allSatisfy(self.contains)
    }
}
