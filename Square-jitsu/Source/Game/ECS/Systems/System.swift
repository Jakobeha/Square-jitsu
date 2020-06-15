//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// The system itself is the class.
/// We use a "System" instance for each entity to reduce boilerplate
protocol System {
    var entity: Entity { get }

    init(entity: Entity)
}

extension System {
    var world: World { entity.world! }
}
