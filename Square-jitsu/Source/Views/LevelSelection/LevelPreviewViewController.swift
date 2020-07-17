//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

/// Just displays an image view with the given preview
class LevelPreviewViewController: UIViewController {
    // We use `new` instead of `init` to hide that this is created progmatically and not by an xib / storyboard
    static func new(preview: UIImage) -> LevelPreviewViewController {
        LevelPreviewViewController(preview: preview)
    }

    private let preview: UIImage

    private init(preview: UIImage) {
        self.preview = preview
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("level preview view controller can't be encoded / decoded")
    }

    override func loadView() {
        view = UIImageView(image: preview)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
