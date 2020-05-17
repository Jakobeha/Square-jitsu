//
// Created by Jakob Hain on 5/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// The collection protocol with additional methods, which most collections should still adhere to
protocol StrongerCollection: Sequence, DynamicSettingCodable {
    associatedtype Element

    init<Source: Sequence>(_ sequence: Source) where Element == Source.Element

    var count: Int { get }
}

extension Array: StrongerCollection {}
extension Set: StrongerCollection {}