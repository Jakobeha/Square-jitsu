//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol HasDefault {
    static var defaultValue: Self { get }

    var isDefault: Bool { get }
}

extension Optional: HasDefault {
    static var defaultValue: Optional<Wrapped> { nil }

    var isDefault: Bool { self == nil }
}

extension Array: HasDefault {
    static var defaultValue: [Element] { [] }

    var isDefault: Bool { isEmpty }
}

extension Set: HasDefault {
    static var defaultValue: Set<Element> { [] }

    var isDefault: Bool { isEmpty }
}

extension Dictionary: HasDefault {
    static var defaultValue: [Key:Value] { [:] }

    var isDefault: Bool { isEmpty }
}

extension Int: HasDefault {
    static var defaultValue: Int = 0

    var isDefault: Bool { self == 0 }
}

extension String: HasDefault {
    static var defaultValue: String { "" }

    var isDefault: Bool { isEmpty }
}