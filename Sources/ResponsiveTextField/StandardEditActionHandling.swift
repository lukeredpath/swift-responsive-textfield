//
//  StandardEditActionHandling.swift
//

import UIKit

/// Defines all of the standard editing actions that can be performed.
///
/// Each action corresponds to a property in `StandardEditActionHandling`.
///
public enum StandardEditAction: Equatable, CaseIterable {
    case cut
    case copy
    case paste
    case delete
    case select
    case selectAll
    case toggleBoldface
    case toggleItalics
    case toggleUnderline
    case makeTextWritingDirectionLeftToRight
    case makeTextWritingDirectionRightToLeft
    case increaseSize
    case decreaseSize
    case updateTextAttributes
}

/// A protocol-witness style implementation of the `UIResponderStandardEditActions`
/// protocol that can be used to override the default behaviour of `UITextField`.
///
/// All of the functions return a `Bool`. Returning `false` to prevent the default behaviour.
///
/// - See Also: `UIResponderStandardEditActions` documentation for more details on
/// what each editing action does.
///
public struct StandardEditActionHandling<Responder: UIResponder> {
    // MARK: - Handling cut, copy and paste commands

    public typealias StandardEditingAction = (Responder, Any?) -> Bool

    public var cut: StandardEditingAction?
    public var copy: StandardEditingAction?
    public var paste: StandardEditingAction?
    public var delete: StandardEditingAction?

    // MARK: - Handling selection commands

    public var select: StandardEditingAction?
    public var selectAll: StandardEditingAction?

    // MARK: - Handling styled text editing

    public var toggleBoldface: StandardEditingAction?
    public var toggleItalics: StandardEditingAction?
    public var toggleUnderline: StandardEditingAction?

    // MARK: - Handling writing direction changes

    public var makeTextWritingDirectionLeftToRight: StandardEditingAction?
    public var makeTextWritingDirectionRightToLeft: StandardEditingAction?

    // MARK: - Handling size changes

    public var increaseSize: StandardEditingAction?
    public var decreaseSize: StandardEditingAction?

    // MARK: - Handling other text formatting changes

    public typealias ConversionHandler = ([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any]

    public var updateTextAttributes: ((Responder, ConversionHandler) -> Bool)?

    public init(
        cut: StandardEditingAction? = nil,
        copy: StandardEditingAction? = nil,
        paste: StandardEditingAction? = nil,
        delete: StandardEditingAction? = nil,
        select: StandardEditingAction? = nil,
        selectAll: StandardEditingAction? = nil,
        toggleBoldface: StandardEditingAction? = nil,
        toggleItalics: StandardEditingAction? = nil,
        toggleUnderline: StandardEditingAction? = nil,
        makeTextWritingDirectionLeftToRight: StandardEditingAction? = nil,
        makeTextWritingDirectionRightToLeft: StandardEditingAction? = nil,
        increaseSize: StandardEditingAction? = nil,
        decreaseSize: StandardEditingAction? = nil,
        updateTextAttributes: ((Responder, ConversionHandler) -> Bool)? = nil
    ) {
        self.cut = cut
        self.copy = copy
        self.paste = paste
        self.delete = delete
        self.select = select
        self.selectAll = selectAll
        self.toggleBoldface = toggleBoldface
        self.toggleItalics = toggleItalics
        self.toggleUnderline = toggleUnderline
        self.makeTextWritingDirectionLeftToRight = makeTextWritingDirectionLeftToRight
        self.makeTextWritingDirectionRightToLeft = makeTextWritingDirectionRightToLeft
        self.increaseSize = increaseSize
        self.decreaseSize = decreaseSize
        self.updateTextAttributes = updateTextAttributes
    }
}

// MARK: - Supported standard editing actions

extension _UnderlyingTextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let supportedActions = supportedStandardEditActions else {
            return super.canPerformAction(action, withSender: true)
        }
        switch action {
        case #selector(cut(_:)):
            return supportedActions.contains(.cut)
        case #selector(copy(_:)):
            return supportedActions.contains(.copy)
        case #selector(paste(_:)):
            return supportedActions.contains(.paste)
        case #selector(select(_:)):
            return supportedActions.contains(.select)
        case #selector(selectAll(_:)):
            return supportedActions.contains(.selectAll)
        case #selector(toggleBoldface(_:)):
            return supportedActions.contains(.toggleBoldface)
        case #selector(toggleItalics(_:)):
            return supportedActions.contains(.toggleItalics)
        case #selector(toggleUnderline(_:)):
            return supportedActions.contains(.toggleUnderline)
        case #selector(makeTextWritingDirectionLeftToRight(_:)):
            return supportedActions.contains(.makeTextWritingDirectionLeftToRight)
        case #selector(makeTextWritingDirectionRightToLeft(_:)):
            return supportedActions.contains(.makeTextWritingDirectionRightToLeft)
        case #selector(increaseSize(_:)):
            return supportedActions.contains(.increaseSize)
        case #selector(decreaseSize(_:)):
            return supportedActions.contains(.decreaseSize)
        case #selector(updateTextAttributes(conversionHandler:)):
            return supportedActions.contains(.updateTextAttributes)
        default:
            // Return the default for any unhandled actions
            return super.canPerformAction(action, withSender: true)
        }
    }
}

// MARK: - Standard editing action handling

extension _UnderlyingTextField {
    override func cut(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.cut(sender)
            return
        }
        if actions.cut?(self, sender) == true {
            super.cut(sender)
        }
    }

    override func copy(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.copy(sender)
            return
        }
        if actions.copy?(self, sender) == true {
            super.copy(sender)
        }
    }

    override func paste(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.paste(sender)
            return
        }
        if actions.paste?(self, sender) == true {
            super.paste(sender)
        }
    }

    override func select(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.select(sender)
            return
        }
        if actions.select?(self, sender) == true {
            super.select(sender)
        }
    }

    override func selectAll(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.selectAll(sender)
            return
        }
        if actions.selectAll?(self, sender) == true {
            super.selectAll(sender)
        }
    }

    override func toggleBoldface(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.toggleBoldface(sender)
            return
        }
        if actions.toggleBoldface?(self, sender) == true {
            super.toggleBoldface(sender)
        }
    }

    override func toggleItalics(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.toggleItalics(sender)
            return
        }
        if actions.toggleItalics?(self, sender) == true {
            super.toggleItalics(sender)
        }
    }

    override func toggleUnderline(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.toggleUnderline(sender)
            return
        }
        if actions.toggleUnderline?(self, sender) == true {
            super.toggleUnderline(sender)
        }
    }

    override func makeTextWritingDirectionLeftToRight(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.makeTextWritingDirectionLeftToRight(sender)
            return
        }
        if actions.makeTextWritingDirectionLeftToRight?(self, sender) == true {
            super.makeTextWritingDirectionLeftToRight(sender)
        }
    }

    override func makeTextWritingDirectionRightToLeft(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.makeTextWritingDirectionRightToLeft(sender)
            return
        }
        if actions.makeTextWritingDirectionRightToLeft?(self, sender) == true {
            super.makeTextWritingDirectionRightToLeft(sender)
        }
    }

    override func increaseSize(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.increaseSize(sender)
            return
        }
        if actions.increaseSize?(self, sender) == true {
            super.increaseSize(sender)
        }
    }

    override func decreaseSize(_ sender: Any?) {
        guard let actions = standardEditActionHandler else {
            super.decreaseSize(sender)
            return
        }
        if actions.decreaseSize?(self, sender) == true {
            super.decreaseSize(sender)
        }
    }

    override func updateTextAttributes(conversionHandler: ([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any]) {
        guard let actions = standardEditActionHandler else {
            super.updateTextAttributes(conversionHandler: conversionHandler)
            return
        }
        if actions.updateTextAttributes?(self, conversionHandler) == true {
            super.updateTextAttributes(conversionHandler: conversionHandler)
        }
    }
}
