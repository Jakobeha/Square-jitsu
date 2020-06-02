//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol JSONCodable {
    func encodeToJson() throws -> JSON
    init(from json: JSON) throws
}
