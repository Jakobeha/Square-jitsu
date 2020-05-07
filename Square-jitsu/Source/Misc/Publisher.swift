//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Publisher<Event> {
    private class ObserverHandlerWrapper<Event> {
        let receive: (Event)->()

        init(_ handler: @escaping (Event) -> ()) {
            self.receive = handler
        }
    }

    private var observers: MapTable<AnyObject, ObserverHandlerWrapper<Event>> = MapTable(keyOptions: .weakMemory)

    func subscribe(observer: AnyObject, handler: @escaping (Event) -> ()) {
        assert(observers[observer] == nil, "already subscribed")
        observers[observer] = ObserverHandlerWrapper(handler)
    }

    func unsubscribe(observer: AnyObject) {
        assert(observers[observer] != nil, "not subscribed")
        observers[observer] = nil
    }

    func publish(_ event: Event) {
        for handlerWrapped in observers.values {
            handlerWrapped.receive(event)
        }
    }
}

extension Publisher where Event == () {
    func publish() {
        publish(())
    }
}
