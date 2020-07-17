//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelItemCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    static let widthHeight: CGFloat = 128
    private static let iconAlphaWhileBeingCut: CGFloat = 0.5

    @IBOutlet private var label: UILabel! = nil
    @IBOutlet private var renameTextField: UITextField! = nil
    @IBOutlet private var iconImageView: UIImageView! = nil
    @IBOutlet private var cutRibbonImageView: UIImageView! = nil
    @IBOutlet private var copyRibbonImageView: UIImageView! = nil

    private lazy var renameGestureRecognizer: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startRenaming))

    var levelItem: LevelItem? = nil {
        didSet {
            label.text = levelItem?.label ?? LevelItem.loadingLabel
            renameTextField.placeholder = levelItem?.label ?? LevelItem.loadingLabel
            renameTextField.text = levelItem?.label ?? LevelItem.loadingLabel
            iconImageView.image = levelItem?.icon ?? LevelItem.unknownIcon

            updateRenameGestureRecognizer()
        }
    }

    weak var delegate: LevelItemCollectionViewCellDelegate! = nil

    var clipboardState: LevelItemClipboardState = .none {
        didSet {
            switch clipboardState {
            case .none:
                cutRibbonImageView.isHidden = true
                copyRibbonImageView.isHidden = true
                iconImageView.alpha = 1
            case .beingCut:
                cutRibbonImageView.isHidden = false
                copyRibbonImageView.isHidden = true
                iconImageView.alpha = LevelItemCollectionViewCell.iconAlphaWhileBeingCut
            case .beingCopied:
                cutRibbonImageView.isHidden = true
                copyRibbonImageView.isHidden = false
                iconImageView.alpha = 1
            }

            updateRenameGestureRecognizer()
        }
    }

    var isRenaming: Bool = false {
        didSet {
            if isRenaming {
                assert(levelItem != nil, "can't rename cell without level item")
                assert(levelItem!.url != nil, "can't rename level item without url")
            }

            label.isHidden = isRenaming
            renameTextField.isHidden = !isRenaming
            if oldValue && !isRenaming {
                renameTextField.resignFirstResponder()
            } else if !oldValue && isRenaming {
                // The text might be from an old failed rename
                renameTextField.text = label.text
                renameTextField.selectAll(nil)
                renameTextField.becomeFirstResponder()
                renameTextField.delegate = self
            }
        }
    }

    var currentRenameText: String {
        renameTextField.text ?? ""
    }

    override var isHighlighted: Bool {
        didSet { backgroundImageView.isHidden = !isHighlighted }
    }

    override var isSelected: Bool {
        didSet {
            selectedBackgroundImageView.isHidden = !isSelected

            updateRenameGestureRecognizer()
        }
    }

    private var backgroundImageView: UIImageView {
        backgroundView! as! UIImageView
    }

    private var selectedBackgroundImageView: UIImageView {
        selectedBackgroundView! as! UIImageView
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        levelItem = nil
        isHighlighted = false
        clipboardState = .none
    }

    // region gesture handling
    private func updateRenameGestureRecognizer() {
        label.gestureRecognizers = canRename ? [renameGestureRecognizer] : []
        if !canRename && isRenaming {
            isRenaming = false
        }
    }

    private var canRename: Bool {
        levelItem != nil && levelItem!.canBeRenamed && !isSelected && clipboardState == .none
    }

    @objc func startRenaming() {
        if isRenaming {
            Logger.warn("level item cell tried to start renaming but it's already renaming")
        } else {
            delegate.startRenaming(levelItem: levelItem!)
        }
    }
    // endregion

    // region text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        assert(renameTextField == textField)

        let newTextToRename = textField.text ?? ""
        isRenaming = false

        if !newTextToRename.isEmpty {
            delegate.rename(cell: self, newName: newTextToRename)
        }

        return false
    }
    // endregion
}
