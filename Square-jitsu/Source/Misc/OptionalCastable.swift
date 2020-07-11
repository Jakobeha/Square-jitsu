//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol OptionalCastable {
    associatedtype Wrapped

    var toOptional: Wrapped? { get }
}

extension Optional: OptionalCastable {
    var toOptional: Wrapped? { self }
}