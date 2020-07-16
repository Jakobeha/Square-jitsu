//
// Created by Jakob Hain on 7/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Reference where you can observe when the value was changed
class ObservableRef<Value> {
    var value: Value {
        didSet { _didChangeValue.publish() }
    }

    private let _didChangeValue: Publisher<()> = Publisher()
    var didChangeValue: Observable<()> { Observable(publisher: _didChangeValue) }

    init(_ initialValue: Value) {
        value = initialValue
    }
}
