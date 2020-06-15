//
// Created by Jakob Hain on 6/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Collection where Element: Monoid {
    func reduce() -> Element {
        reduce(Element.mempty) { $0.mappend($1) }
    }
}
