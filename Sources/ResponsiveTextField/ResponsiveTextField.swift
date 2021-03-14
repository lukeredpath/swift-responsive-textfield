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

    /// A binding to the editing state of the text field.
    ///
    /// This will synchronise with the textfield's first responder state - it will get updated
    /// if the user taps on the textfield (making it first responder) or if the text field resigns
    /// first responder status. It can also allow the containing view to manually control
    /// the first responder state by setting it to true or false.
    let isEditing: Binding<Bool>

    /// Enables secure text entry.
    ///
    /// This field can be updated, allowing you to toggle secure entry on and off using
    /// some external state.
    let isSecure: Bool

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

    /// A callback function that will be called when the user taps the keyboard return button.
    /// If this is not set, the textfield delegate will indicate that the return key is not handled.
    var handleReturn: (() -> Void)?

    public init(
        placeholder: String,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        isSecure: Bool = false,
        configuration: Configuration = .empty,
        handleReturn: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.isEditing = isEditing
        self.isSecure = isSecure
        self.configuration = configuration
        self.handleReturn = handleReturn
    }
}

// MARK: - UIViewRepresentable

extension ResponsiveTextField: UIViewRepresentable {
    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        configuration.configure(textField)
        // This stops the text field from expanding if the text overflows the frame width
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

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.isEnabled = isEnabled
        uiView.isSecureTextEntry = isSecure
        uiView.returnKeyType = returnKeyType
        uiView.font = font

        switch (uiView.isFirstResponder, isEditing.wrappedValue) {
        case (true, false):
            uiView.resignFirstResponder()
        case (false, true):
            uiView.becomeFirstResponder()
        default:
            break
        }
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        let parent: ResponsiveTextField

        @Binding
        var text: String

        @Binding
        var isEditing: Bool

        init(textField: ResponsiveTextField) {
            self.parent = textField
            self._text = textField.text
            self._isEditing = textField.isEditing
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            // Scheduled on the next runloop to avoid runtime warnings
            // about changing state during a view update.
            RunLoop.main.schedule { self.isEditing = true }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            // Scheduled on the next runloop to avoid runtime warnings
            // about changing state during a view update.
            RunLoop.main.schedule { self.isEditing = false }
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let handleReturn = parent.handleReturn {
                handleReturn()
                return true
            }
            return false
        }

        @objc func textFieldTextChanged(_ textField: UITextField) {
            self.text = textField.text ?? ""
        }
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
    func responsiveKeyboardReturnType(_ returnType: UIReturnKeyType) -> some View {
        environment(\.keyboardReturnKeyType, returnType)
    }

    func responsiveTextFieldFont(_ font: UIFont) -> some View {
        environment(\.textFieldFont, font)
    }

    func responsiveTextFieldTextColor(_ color: UIColor) -> some View {
        environment(\.textFieldTextColor, color)
    }

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
        var isEditing: Bool = false

        var body: some View {
            ResponsiveTextField(
                placeholder: "Placeholder",
                text: $text,
                isEditing: $isEditing,
                configuration: configuration
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
