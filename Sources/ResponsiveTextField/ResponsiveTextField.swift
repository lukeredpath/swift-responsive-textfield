//
//  ResponsiveTextField.swift
//

import UIKit
import SwiftUI

// MARK: - Main Interface

/// A SwiftUI wrapper around UITextField that gives precise control over the responder state.
///
public struct ResponsiveTextField {
    /// The text field placeholder string
    let placeholder: String

    /// A binding to the text state that will hold the typed text
    let text: Binding<String>

    /// Enables secure text entry.
    ///
    /// This field can be updated, allowing you to toggle secure entry on and off using
    /// some external state.
    let isSecure: Bool

    /// Can be used to programatically control the text field's first responder state.
    ///
    /// When the binding's wrapped value is set, it will cause the text field to try and become or resign first responder status
    /// either on first initialisation or on subsequent view updates.
    ///
    /// A wrapped value of `nil` indicates there is no demand (or any previous demand has been fulfilled).
    ///
    /// To detect when the text field actually becomes or resigns first responder, use the
    /// `.onFirstResponderChange()` callback function.
    var firstResponderDemand: Binding<FirstResponderDemand?>?

    /// Allows for the text field to be configured during creation.
    let configuration: Configuration

    /// Controls whether or not the textfield is enabled, using the SwiftUI environment.
    /// To disable the textfield, you can use the standard SwiftUI `.disabled()`
    /// modifier.
    @Environment(\.isEnabled)
    var isEnabled: Bool

    /// Sets the keyboard return type - use the `.responsiveKeyboardReturnType()` modifier.
    @Environment(\.keyboardReturnKeyType)
    var returnKeyType: UIReturnKeyType

    /// Sets the text field font - use the `.responsiveKeyboardFont()` modifier.
    @Environment(\.textFieldFont)
    var font: UIFont

    /// Sets the text field color - use the `.responsiveTextFieldColor()` modifier.
    @Environment(\.textFieldTextColor)
    var textColor: UIColor

    /// Sets the text field alignment - use the w`.textFieldTextAlignemnt()` modifier.
    @Environment(\.textFieldTextAlignment)
    var textAlignment: NSTextAlignment

    /// A calllback function that will be called whenever the first responder state changes.
    var onFirstResponderStateChanged: FirstResponderStateChangeHandler?

    /// A callback function that will be called when the user taps the keyboard return button.
    /// If this is not set, the textfield delegate will indicate that the return key is not handled.
    var handleReturn: (() -> Void)?

    /// A callback function that will be called when the user deletes backwards.
    ///
    /// Takes a single argument - a `String` - which will be the current text when the user
    /// hits the delete key (but before any deletion occurs).
    ///
    /// If this is an empty string, it indicates that the user tapped delete inside an empty field.
    var handleDelete: ((String) -> Void)?

    /// A callback function that can be used to control whether or not text should change.
    ///
    /// Takes two `String` arguments - the text prior to the change and the new text if
    /// the change is permitted.
    ///
    /// Return `true` to allow the change or `false` to prevent the change.
    var shouldChange: ((String, String) -> Bool)?

    /// A list of supported standard editing actions.
    ///
    /// When set, this will override the default standard edit actions for a `UITextField`. Leave
    /// set to `nil` if you only want to support the default actions.
    ///
    /// You can use this property and `standardEditActionHandler` to support both the
    /// range of standard editing actions and how each editing action should be handled.
    ///
    /// If you exclude an edit action from this list, any corresponding action handler set in
    /// any provided `standardEditActionHandler` will not be called.
    var supportedStandardEditActions: Set<StandardEditAction>?

    /// Can be set to provide custom standard editing action behaviour.
    ///
    /// When `nil`, all standard editing actions will result in the default `UITextField` behaviour.
    ///
    /// When set, any overridden actions will be called and if the action handler returns `true`, the
    /// default `UITextField` behaviour will also be called. If the action handler returns `false`,
    /// the default behaviour will not be called.
    ///
    /// If the provided type does not implement a particular editing action, the default `UITextField`
    /// behaviour will be called.
    var standardEditActionHandler: StandardEditActionHandling<UITextField>?

    fileprivate var shouldUpdateView: Bool = true

    public init(
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        firstResponderDemand: Binding<FirstResponderDemand?>? = nil,
        configuration: Configuration = .empty,
        onFirstResponderStateChanged: FirstResponderStateChangeHandler? = nil,
        handleReturn: (() -> Void)? = nil,
        handleDelete: ((String) -> Void)? = nil,
        shouldChange: ((String, String) -> Bool)? = nil,
        supportedStandardEditActions: Set<StandardEditAction>? = nil,
        standardEditActionHandler: StandardEditActionHandling<UITextField>? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.firstResponderDemand = firstResponderDemand
        self.isSecure = isSecure
        self.configuration = configuration
        self.onFirstResponderStateChanged = onFirstResponderStateChanged
        self.handleReturn = handleReturn
        self.handleDelete = handleDelete
        self.shouldChange = shouldChange
        self.supportedStandardEditActions = supportedStandardEditActions
        self.standardEditActionHandler = standardEditActionHandler
    }

    fileprivate mutating func firstResponderDemandFulfilled() {
        shouldUpdateView = false
        firstResponderDemand?.wrappedValue = nil
        shouldUpdateView = false
    }
}

// MARK: - Managing the first responder state

public struct FirstResponderStateChangeHandler {
    /// A closure that will be called when the first responder state changes.
    ///
    /// - Parameters:
    ///     - Bool: A boolean indicating if the text field is now the first responder or not.
    ///
    public var handleStateChange: (Bool) -> Void

    public init(handleStateChange: @escaping (Bool) -> Void) {
        self.handleStateChange = handleStateChange
    }

    func callAsFunction(_ isFirstResponder: Bool) {
        handleStateChange(isFirstResponder)
    }
}

/// Represents a request to change the text field's first responder state.
///
public enum FirstResponderDemand: Equatable {
    /// The text field should become first responder on the next view update.
    case shouldBecomeFirstResponder

    /// The text field should resign first responder on the next view update.
    case shouldResignFirstResponder
}

// MARK: - UIViewRepresentable implementation

extension ResponsiveTextField: UIViewRepresentable {
    public func makeUIView(context: Context) -> UITextField {
        let textField = _UnderlyingTextField()
        configuration.configure(textField)
        // This stops the text field from expanding if the text overflows the frame width
        textField.handleDelete = handleDelete
        textField.supportedStandardEditActions = supportedStandardEditActions
        textField.standardEditActionHandler = standardEditActionHandler
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.placeholder = placeholder
        textField.text = text.wrappedValue
        textField.isEnabled = isEnabled
        textField.isSecureTextEntry = isSecure
        textField.font = font
        textField.textColor = textColor
        textField.textAlignment = textAlignment
        textField.returnKeyType = returnKeyType
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator,
            action: #selector(Coordinator.textFieldTextChanged(_:)),
            for: .editingChanged
        )
        return textField
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(textField: self)
    }

    /// Will update the text view when the containing view triggers a body re-calculation.
    ///
    /// If the first responder state has changed, this may trigger the textfield to become or resign
    /// first responder status.
    ///
    public func updateUIView(_ uiView: UITextField, context: Context) {
        guard shouldUpdateView else { return }

        uiView.isEnabled = isEnabled
        uiView.isSecureTextEntry = isSecure
        uiView.returnKeyType = returnKeyType
        uiView.font = font

        switch (uiView.isFirstResponder, firstResponderDemand?.wrappedValue) {
        case (true, .shouldResignFirstResponder):
            uiView.resignFirstResponder()
        case (false, .shouldBecomeFirstResponder):
            uiView.becomeFirstResponder()
        default:
            context.coordinator.resetFirstResponderDemand()
        }
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ResponsiveTextField

        @Binding
        var text: String

        init(textField: ResponsiveTextField) {
            self.parent = textField
            self._text = textField.text
        }

        public func resetFirstResponderDemand() {
            parent.firstResponderDemandFulfilled()
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFirstResponderStateChanged?(true)
            parent.firstResponderDemandFulfilled()
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFirstResponderStateChanged?(false)
            parent.firstResponderDemandFulfilled()
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let handleReturn = parent.handleReturn {
                handleReturn()
                return true
            }
            return false
        }

        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let shouldChange = parent.shouldChange {
                let currentText = textField.text ?? ""
                guard let newRange = Range(range, in: currentText) else {
                    return false // when would this conversion fail?
                }
                let newText = currentText.replacingCharacters(in: newRange, with: string)
                return shouldChange(currentText, newText)
            }
            return true
        }

        @objc func textFieldTextChanged(_ textField: UITextField) {
            self.text = textField.text ?? ""
        }
    }
}

class _UnderlyingTextField: UITextField {
    var handleDelete: ((String) -> Void)?
    var supportedStandardEditActions: Set<StandardEditAction>?
    var standardEditActionHandler: StandardEditActionHandling<UITextField>?

    override func deleteBackward() {
        handleDelete?(text ?? "")
        super.deleteBackward()
    }
}

// MARK: - TextField Configurations

extension ResponsiveTextField {
    /// Provides a way of configuring the underlying UITextField inside a ResponsiveTextField.
    ///
    /// All ResponsiveTextFields take a configuration which lets you package up common configurations
    /// that you use in your app. Configurations are composable and can be combined to create more
    /// detailed configurations.
    ///
    public struct Configuration {
        var configure: (UITextField) -> Void

        public init(configure: @escaping (UITextField) -> Void) {
            self.configure = configure
        }

        public static func combine(_ configurations: Self...) -> Self {
            combine(configurations)
        }

        public static func combine(_ configurations: [Self]) -> Self {
            .init { textField in
                for configuration in configurations {
                    configuration.configure(textField)
                }
            }
        }
    }
}

// MARK: - Built-in Configuration Values

public extension ResponsiveTextField.Configuration {
    static let empty = Self { _ in }

    static let partOfChain = Self {
        $0.returnKeyType = .next
    }

    static let lastOfChain = Self {
        $0.returnKeyType = .done
    }

    static let autoclears = Self {
        $0.clearsOnBeginEditing = true
    }

    static let email = Self {
        $0.keyboardType = .emailAddress
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.clearButtonMode = .whileEditing
    }

    static let password = Self {
        $0.keyboardType = .default
        $0.isSecureTextEntry = true
        $0.spellCheckingType = .no
    }
}

// MARK: - View Modifiers

public extension View {
    /// Sets the keyboard return key type on any child `ResponsiveTextField` views.
    func responsiveKeyboardReturnType(_ returnType: UIReturnKeyType) -> some View {
        environment(\.keyboardReturnKeyType, returnType)
    }

    /// Sets the text field font on any child `ResponsiveTextField` views.
    func responsiveTextFieldFont(_ font: UIFont) -> some View {
        environment(\.textFieldFont, font)
    }

    /// Sets the text field text color on any child `ResponsiveTextField` views.
    func responsiveTextFieldTextColor(_ color: UIColor) -> some View {
        environment(\.textFieldTextColor, color)
    }

    /// Sets the text field text alignment on any child `ResponsiveTextField` views.
    func responsiveTextFieldTextAlignment(_ alignment: NSTextAlignment) -> some View {
        environment(\.textFieldTextAlignment, alignment)
    }
}

// MARK: - Previews

struct ResponsiveTextField_Previews: PreviewProvider {
    struct TextFieldPreview: View {
        let configuration: ResponsiveTextField.Configuration

        @State
        var text: String = ""

        @State
        var firstResponderDemand: FirstResponderDemand? = .shouldBecomeFirstResponder

        var body: some View {
            ResponsiveTextField(
                placeholder: "Placeholder",
                text: $text,
                firstResponderDemand: $firstResponderDemand,
                configuration: configuration,
                shouldChange: { $1.count <= 10 }
            )
            .fixedSize(horizontal: false, vertical: true)
            .padding()
        }
    }

    static var previews: some View {
        Group {
            TextFieldPreview(configuration: .empty)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Empty Field")

            TextFieldPreview(configuration: .email, text: "example@example.com")
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Email Field")

            TextFieldPreview(configuration: .email, text: "example@example.com")
                .responsiveTextFieldFont(.preferredFont(forTextStyle: .title2))
                .responsiveTextFieldTextColor(.systemBlue)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Text Styling")

            TextFieldPreview(configuration: .empty, text: "This is some text")
                .responsiveTextFieldTextAlignment(.center)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Custom Alignment")

            TextFieldPreview(configuration: .empty, text: "This is some text")
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled Field")
        }
    }
}
