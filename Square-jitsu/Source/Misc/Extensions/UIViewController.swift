//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

extension UIViewController {
    private static var defaultStoryboardName: String {
        String(description().split(separator: ".").last!)
    }

    static func getDefaultStoryboard() -> UIStoryboard {
        UIStoryboard(name: defaultStoryboardName, bundle: Bundle.main)
    }
}
