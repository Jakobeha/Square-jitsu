//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Publisher<Event> {
    private class ObserverInfo<Event> {
        let priority: ObservablePriority
        let receive: (Event)->()

        init(priority: ObservablePriority, handler: @escaping (Event) -> ()) {
            self.priority = priority
            self.receive = handler
        }
    }

    private var observers: MapTable<AnyObject, ObserverInfo<Event>> = MapTable(keyOptions: .weakMemory)

    private var sortedObservers: [ObserverInfo<Event>] {
        observers.values.sorted { $0.priority > $1.priority }
    }

    /// Higher priority = receives messages earlier (this is bad design)
    func subscribe(observer: AnyObject, priority: ObservablePriority, handler: @escaping (Event) -> ()) {
        assert(observers[observer] == nil, "already subscribed")
        observers[observer] = ObserverInfo(priority: priority, handler: handler)
    }

    func unsubscribe(observer: AnyObject) {
        assert(observers[observer] != nil, "not subscribed")
        observers[observer] = nil
    }

    func publish(_ event: Event) {
        for handlerWrapped in sortedObservers {
            handlerWrapped.receive(event)
        }
    }
}

extension Publisher where Event == () {
    func publish() {
        publish(())
    }
}
