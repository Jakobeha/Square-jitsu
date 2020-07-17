//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Set where Element == URL {
    /// Removes a URL if a parent directory is also in the set
    var coalesced: Set<URL> {
        filter { url in !self.contains(anyOf: url.localAncestors.dropFirst()) }
    }
}
