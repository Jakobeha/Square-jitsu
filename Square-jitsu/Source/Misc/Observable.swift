//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct Observable<Event> {
    private let publisher: Publisher<Event>

    init(publisher: Publisher<Event>) {
        self.publisher = publisher
    }

    func subscribe(observer: AnyObject, handler: @escaping (Event) -> ()) {
        publisher.subscribe(observer: observer, handler: handler)
    }

    func unsubscribe(observer: AnyObject) {
        publisher.unsubscribe(observer: observer)
    }
}
