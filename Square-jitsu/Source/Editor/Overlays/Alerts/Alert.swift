//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Alert: EmptyBlockingOverlay {
    let message: String
    let subtext: String?
    let options: [AlertOption]
    private let action: (AlertOption) -> Void

    init<Option: AlertOption>(message: String, subtext: String?, options: [Option], action: @escaping (Option) -> ()) {
        self.message = message
        self.subtext = subtext
        self.options = options
        self.action = { selectedOption in
            action(selectedOption as! Option)
        }
        super.init()
    }

    func selectOption(index: Int) {
        let selectedOption = options[index]
        action(selectedOption)
        dismissIfVisible()
    }
}
