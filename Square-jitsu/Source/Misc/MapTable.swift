//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct MapTable<Key: AnyObject, Value: AnyObject> {
    private let wrapped: NSMapTable<Key, Value>

    init(keyOptions: NSPointerFunctions.Options) {
        wrapped = NSMapTable(keyOptions: keyOptions)
    }

    subscript(key: Key) -> Value? {
        get { wrapped.object(forKey: key) }
        set {
            if newValue == nil {
                wrapped.removeObject(forKey: key)
            } else {
                wrapped.setObject(newValue, forKey: key)
            }
        }
    }

    var values: [Value] {
        let enumerator = wrapped.objectEnumerator()!
        return enumerator.map { $0 as! Value }
    }
}
