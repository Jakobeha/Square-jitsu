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

    func subscribe<Observer: AnyObject>(observer: Observer, priority: ObservablePriority, handler: @escaping (Observer, Event) -> ()) {
        publisher.subscribe(observer: observer, priority: priority, handler: handler)
    }

    func unsubscribe(observer: AnyObject) {
        publisher.unsubscribe(observer: observer)
    }
}

extension Observable where Event == () {
    func subscribe<Observer: AnyObject>(observer: Observer, priority: ObservablePriority, handler: @escaping (Observer) -> ()) {
        publisher.subscribe(observer: observer, priority: priority, handler: handler)
    }
}
