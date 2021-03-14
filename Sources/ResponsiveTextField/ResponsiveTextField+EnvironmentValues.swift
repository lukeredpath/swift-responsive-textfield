//
//  ResponsiveTextField+EnvironmentValues.swift
//  TextField
//
//  Created by Luke Redpath on 14/03/2021.
//

import SwiftUI

// MARK: - Environment Keys

private struct KeyboardReturnTypeKey: EnvironmentKey {
    static let defaultValue: UIReturnKeyType = .default
}

private struct ResponsiveTextFieldFontKey: EnvironmentKey {
    static let defaultValue: UIFont = .preferredFont(forTextStyle: .body)
}

private struct ResponsiveTextFieldTextColorKey: EnvironmentKey {
    static let defaultValue: UIColor = .black
}

private struct ResponsiveTextFieldTextAlignmentKey: EnvironmentKey {
    static let defaultValue: NSTextAlignment = .natural
}

// MARK: - Environment Values

extension EnvironmentValues {
    var keyboardReturnKeyType: UIReturnKeyType {
        get { self[KeyboardReturnTypeKey.self] }
        set { self[KeyboardReturnTypeKey.self] = newValue }
    }

    var textFieldFont: UIFont {
        get { self[ResponsiveTextFieldFontKey.self] }
        set { self[ResponsiveTextFieldFontKey.self] = newValue }
    }

    var textFieldTextColor: UIColor {
        get { self[ResponsiveTextFieldTextColorKey.self] }
        set { self[ResponsiveTextFieldTextColorKey.self] = newValue }
    }

    var textFieldTextAlignment: NSTextAlignment {
        get { self[ResponsiveTextFieldTextAlignmentKey.self] }
        set { self[ResponsiveTextFieldTextAlignmentKey.self] = newValue }
    }
}
