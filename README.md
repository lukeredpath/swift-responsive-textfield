# ResponsiveTextField

This library aims to achieve one goal, which is provide a reasonably flexible
and useful SwiftUI wrapper around UITextField that provides more control over
it's first responder status, one of the most glaring omissions from SwiftUI's
native TextField even in iOS 14.

## Features

At a high level, it provides:

* A simple API, making use of SwiftUI bindings to capture entered text and
  control the text field's first responder status.
* The ability to set the text field's placeholder.
* Support for secure text entry.
* The ability to handle return key taps.
* The ability to style the text field using SwiftUI-style view modifiers.
* Support for enabling and disabling the text field using the SwiftUI
  Environment.
* A composable configuration system for detailed configuration of the underlying
  UITextField.

The following features are not currently supported:

* Control over if the text field should begin or end editing using the
  UITextFieldDelegate methods.
* Control over how text should be replaced or cleared.
* Managing the text selection.
* Any of the built-in attributed string supporting APIs.

Most UITextField APIs that are not exposed directly can be managed using the
text field configuration system.

## Installation

The library is made available as a Swift package and can be added to your
project using Xcode's built-in package management tools.

## Usage

### Getting Started

To use `ResponsiveTextField` you will need to provide it with, at a minimum,
a placeholder string, a `Binding<String>` to capture the text entered into the
text field and a `Binding<Bool>` to manage the text field's first responder
status.

```swift
struct ExampleView: View {
  @State var email: String
  @State var isEditingEmail: Bool

  var body: some View {
    VStack {
      ResponsiveTextField(
          placeholder: "Email address",
          text: $email,
          isEditing: $isEditingEmail
      )
    }
  }
}
```

Out of the box, `ResponsiveTextField` will fill the width of it's container and
will not expand if text overflows the available space. It will also try and fill
the height of its container - you can fix its height to its intrinsic content
size using the `.fixedSize` modifier:

```swift
ResponsiveTextField(
    placeholder: "Email address",
    text: $email,
    isEditing: $isEditingEmail
)
.fixedSize(horizontal: false, vertical: true)
```

As the user types in the field, it will update the state that the binding was
derived from.

### Disabling the text field

You can disable the text field using the standard SwiftUI `.disabled` modifier:

```swift

ResponsiveTextField(
    placeholder: "Email address",
    text: $email,
    isEditing: $isEditingEmail
)
.disabled(true)
```

This uses the SwiftUI Environment system so it does not need to be called
directly on the `ResponsiveTextField` element itself - you can also attach it
to any parent view.

The disabled state can be updated and the text field will update it's state
accordingly. This means you can use an `@State` variable to control the disabled
state. No binding is required for this.

Disabling the text field will make it ignore any taps and will also resign the
first responder status if the user was editing when it is disabled.

### Customising the text field appearance

You can control the appearance of the text field, including it's font, text
color, text alignment and return key type using custom view modifiers. These
modifiers also use the Environment system so can be called on any container
view as well as the text field itself. Note - these modifiers take UIKit values
for fonts and colors, not SwiftUI values:

```swift
/// Sets the return key type
textField.responsiveKeyboardReturnType(.next)

/// Sets the text color
textField.responsiveTextFieldTextColor(.red)

/// Sets the font
textField.responsiveTextFieldTextColor(.preferredFont(forTextStyle: .headline))

/// Sets the text alignment
textField.responsiveTextFieldTextAlignment(.center)
```

### Advanced re-usable configuration

For more detailed configuration, you can pass a
`ResponsiveTextField.Configuration` value to the initialiser. This is a value
type that takes a single argument, a closure of `(UITextField) -> Void`. This
allows you to have full control over the properties of the `UITextField`.

Its important to note that this configuration will be called early during the
`makeUIView()` function meaning that certain properties will be overwritten.

```swift
ResponsiveTextField(
    placeholder: "Email address",
    text: $email,
    isEditing: $isEditingEmail,
    configuration: .init {
      $0.autocorrectionType = .no
      $0.clearButtonModde = .whileEditing
    }
)
```

The real power of this type is the ability to create pre-defined configurations
that you can re-use throughout your app. You can define these as static values
in an extension on `ResponsiveTextField.Configuration`.

For example, we may define an `email` configuration that sets the keyboard
type and disables autocorrection:

```swift
public extension ResponsiveTextField.Configuration {
  static let emailField = Self {
        $0.keyboardType = .emailAddress
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.clearButtonMode = .whileEditing
    }
}
```

You can now use this anywhere within your app in a concise way:

```swift
ResponsiveTextField(
    placeholder: "Email address",
    text: $email,
    isEditing: $isEditingEmail,
    configuration: .emailField
)
```

The real power is being able to create small focused configurations that do just
one thing, then combining them to create higher-level configurations. For
example, we could refactor the previous configuration into smaller ones and
then combine them in different ways:

```swift
public extension ResponsiveTextField.Configuration {
  static let noCorrection = Self {
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
    $0.spellCheckingType = .no
  }

  static func keyboardType(_ type: UIKeyboardType) -> Self {
    $0.keyboardType = type
  }

  static let clearWhileEditing = Self {
    $0.clearButtonMode = .whileEditing
  }

  static let emailField = .combine(
    .keyboardtype(.emailAddress),
    .noCorrection,
    .clearWhileEditing
  )

  static let passwordField = .combine(
    .noCorrection,
    .clearWhileEditing
  )
}
```

## Licence

This library is released under the Apache v2.0 license. See [LICENSE](LICENSE)
for details.
