//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

/// Wraps another view controller, which is the actual preview of the level item,
/// with the level item. Also allows externally-provided preview action items
class LevelItemPreviewViewController: UIViewController {
    // We use `new` instead of `init` to hide that this is created progmatically and not by an xib / storyboard
    static func new(content: UIViewController, levelItem: LevelItem) -> LevelItemPreviewViewController {
        LevelItemPreviewViewController(content: content, levelItem: levelItem)
    }

    let levelItem: LevelItem
    private let content: UIViewController

    private var _previewActionItems: [UIPreviewActionItem] = []
    override var previewActionItems: [UIPreviewActionItem] {
        get { _previewActionItems }
        set { _previewActionItems = newValue }
    }

    init(content: UIViewController, levelItem: LevelItem) {
        self.levelItem = levelItem
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("level item preview view controller can't be encoded / decoded")
    }

    override func loadView() {
        view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(content.view)
    }
}
