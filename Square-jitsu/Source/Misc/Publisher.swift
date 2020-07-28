//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Publisher<Event> {
    private class ObserverInfo<Event> {
        let priority: ObserverPriority
        let receive: (Event) -> ()

        init<Observer: AnyObject>(observer: Observer, priority: ObserverPriority, handler: @escaping (Observer, Event) -> ()) {
            self.priority = priority
            self.receive = { [unowned observer] event in
                handler(observer, event)
            }
        }
    }

    private var observers: MapTable<AnyObject, ObserverInfo<Event>> = MapTable(keyOptions: .weakMemory)

    private var sortedObservers: [ObserverInfo<Event>] {
        observers.values.sorted { $0.priority > $1.priority }
    }

    /// Higher priority = receives messages earlier (this is bad design)
    func subscribe<Observer: AnyObject>(observer: Observer, priority: ObserverPriority, handler: @escaping (Observer, Event) -> ()) {
        assert(observers[observer] == nil, "already subscribed")
        observers[observer] = ObserverInfo(observer: observer, priority: priority, handler: handler)
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
    func subscribe<Observer: AnyObject>(observer: Observer, priority: ObserverPriority, handler: @escaping (Observer) -> ()) {
        subscribe(observer: observer, priority: priority) { (observer, _) in
            handler(observer)
        }
    }

    func publish() {
        publish(())
    }
}
