# ResponsiveTextField - a better SwiftUI text field

[![CI](https://github.com/lukeredpath/swift-responsive-textfield/actions/workflows/ci.yml/badge.svg)](https://github.com/lukeredpath/swift-responsive-textfield/actions/workflows/ci.yml)
[![GitHub license](https://img.shields.io/github/license/lukeredpath/swift-responsive-textfield.svg)](https://github.com/lukeredpath/swift-responsive-textfield/blob/master/LICENSE)

This library aims to achieve one goal, which is provide a reasonably flexible
and useful SwiftUI wrapper around UITextField that provides more control over
it's first responder status, one of the most glaring omissions from SwiftUI's
native TextField even in iOS 14.

## Features

At a high level, it provides the ability to:

* Use of SwiftUI bindings to capture entered text and control the text field's
  first responder status.
* Observe and react to the text field's first responder status.
* Set the text field's placeholder.
* Enable secure text entry.
* Easily handle return key and delete key taps with a simple callback.
* Style the text field using SwiftUI-style view modifiers.
* Support for enabling and disabling the text field using the SwiftUI
  `.disabled` view modifier.
* Configure the properties of the underlying text field using a composable
  text field configuration system.
* Control over how and when text changes should be permitted.
* Control over if the text field should begin or end editing.
* Customise which standard edit actions are available (e.g. copy, paste).
* Override and customise the handling of standard edit actions.

The following features are not currently supported:

* Control over how text should be cleared.
* Managing the text selection.
* Any of the built-in attributed string supporting APIs.

Most UITextField APIs that are not exposed directly can be managed using the
text field configuration system.

## Installation

The library is made available as a Swift package and can be added to your
project using Xcode's built-in package management tools.

## Usage

[API Documentation](https://lukeredpath.github.io/swift-responsive-textfield/)

### Getting Started

To use `ResponsiveTextField` you will need to provide it with, at a minimum,
a placeholder string and a `Binding<String>` to capture the text entered into
the text field.

```swift
struct ExampleView: View {
  @State var email: String = ""

  var body: some View {
    VStack {
      ResponsiveTextField(
          placeholder: "Email address",
          text: $email
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
    text: $email
)
.fixedSize(horizontal: false, vertical: true)
```

As the user types in the field, it will update the state that the binding was
derived from.

You can enable secure text entry by passing in the `isSecure` property:

```swift
ResponsiveTextField(
    placeholder: "Email address",
    text: $email,
    isSecure: true
)
```

The `isSecure` property can be updated when the view is updated so it is
possible to control this via some external state property, i.e. to dynamically
enable or disable secure text entry.

### Disabling the text field

You can disable the text field using the standard SwiftUI `.disabled` modifier:

```swift

ResponsiveTextField(
    placeholder: "Email address",
    text: $email
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

## First Responder Control

`ResponsiveTextField` uses the SwiftUI binding system to give programmatic
control over the first responder status of the control. This is one of the
major pieces of missing behaviour from the native `TextField` type.

### Observing the first responder state

When initialised you can pass in a callback function using the parameter
`onFirstResponderStateChanged:` - this takes a value of type
`FirstResponderStateChangeHandler`, which wraps a closure that will be called
with the updated first responder state whenever it changes, either as a result
of some user interaction or as the result of a change in the
`FirstResponderDemand` (see below).

The first responder state is represented as  a single `Bool` value where `true`
indicates that the text field has become  first responder and `false` indicates
that it has resigned first responder.

```swift
struct ExampleView: View {
  var body: some View {
    ResponsiveTextField(
        placeholder: "Email address",
        text: $email,
        configuration: .emailField,
        onFirstResponderStateChanged: .init { isFirstResponder in
          // do something with first responder state
        }
    )
  }
}
```

If you need to track this state you can store it in some external state, such as
an `@State` property or an `@ObservableObject` (like your view model):

```swift
struct ExampleView: View {
  @State
  var isFirstResponder = false

  var body: some View {
    ResponsiveTextField(
        placeholder: "Email address",
        text: $email,
        configuration: .emailField,
        onFirstResponderStateChanged: .init {
          isFirstResponder = $0
        }
    )
  }
}
```

If all you need to do is update some external state, you can use the built-in
`.updates` state changed handler, passing in a binding to that state. The above
example can be simplified to:

```swift
struct ExampleView: View {
  @State
  var isFirstResponder = false

  var body: some View {
    ResponsiveTextField(
        placeholder: "Email address",
        text: $email,
        configuration: .emailField,
        onFirstResponderStateChanged: .updates($isFirstResponder)
    )
  }
}
```

`FirstResponderStateChangeHandler` can also be initialised with a
`canBecomeFirstResponder` and `canResignFirstResponder` closures that both
return a `Bool` - if provided, these will be called in the text field's
`shouldBeginEditing` and `shouldEndEditing` delegate calls and provide flexible
control over if the text field's responder state should change. If these
closures are not provided these delegate methods will return `true`.

### Progamatically controlling the first responder state

`ResponsiveTextField` also supports binding-based control over the field's
first responder state. To control the first responder state, you must
initialise the field with a `Binding<FirstResponderDemand?>`:

```swift
struct ExampleView: View {
  @State
  var responderDemand: FirstResponderDemand?

  var body: some View {
    ResponsiveTextField(
        placeholder: "Email address",
        text: $email,
        firstResponderDemand: $responderDemand
    )
  }
}
```

Whenever the binding's wrapped value changes, it will attempt to trigger  a
responder state change unless the text field's current responder state already
fulfils the demand. Once the demand has been fulfilled the binding's wrapped
value will be set back to `nil`.

#### Becoming first responder

To make the text field become first responder, set the demand to
`.shouldBecomeFirstResponder`. If the text field is already first responder the
binding's wrapped value will be automatically set back to `nil`, otherwise
`becomeFirstResponder()` will be called and the binding's wrapped value will
be set to `nil` once the first responder state has become `isFirstResponder`.

#### Resigning first responder

To make the text field resign first responder, set the demand to
`.shouldResignFirstResponder`. If the text field is not the first responder the
binding's wrapped value will be automatically set back to `nil`, otherwise
`resignFirstResponder()` will be called and the binding's wrapped value will
be set to `nil` once the first responder state has become `notFirstResponder`.

### Avoiding nested view updates

When using a `firstResponderStateChangeHandler` to update some state that
triggers a view update in combination with state-driven first responder changes, it 
is possible to end up in a situation where you are triggering a view update in the 
middle of existing view update cycle which will result in a runtime warning about
undefined behaviour.

This can occur because state-driven first responder changes cause the text field 
to become first responder as part of a view update - this means that the change 
handler itself will be called during that view update so if it was to trigger another
view update when called, it would happen within the current view update. 

In the following example, a warning would occur because the change to the 
`@State` variable results in a nested view update:

```swift
struct ExampleView: View {
  @State
  var someString: String
  
  @State
  var firstText: String
  
  @State
  var secondText: String
  
  @State
  var secondResponderDemand: FirstResponderDemand

  var body: some View {
    Text("The text is: \(someString)")
    ResponsiveTextField(
        placeholder: "First",
        text: $firstText,
        handleReturn: {
            // make the second field become first responder
            secondResponderDemand = .shouldBecomeFirstResponder
        }
    )
    ResponsiveTextField(
        placeholder: "Second",
        text: $secondText,
        firstResponderDemand: 
        onFirstResponderStateChanged: .init { _ in
          // This will be called during the view update triggered
          // by mutating `shouldBecomeFirstResponder` in the first
          // field's `handleReturn` closure.
          // This will trigger a nested state change!
          someString = "Hello World"
        }
    )
  }
}
```

To workaround this problem, rather than the library explicitly calling the state change
handler on the next runloop tick or on an asynchronous `DispatchQueue`, which
might not be necessary if there is no nested state change, you can avoid the 
problem by ensuring that the view update your state change handler triggers 
always happens after the view update completes.

A convenience modifier on `FirstResponderStateChangeHandler`, `receive(on:)`
allows you to do this by passing in a scheduler such as a runloop or dispatch queue.
The above example can be fixed with the following change to the second text field:

```swift
ResponsiveTextField(
    placeholder: "Second",
    text: $secondText,
    firstResponderDemand: 
    onFirstResponderStateChanged: .init { _ in
      // This will now be triggered on the next runloop tick and
      // will not trigger a nested state change warning.
      someString = "Hello World"
    }.receive(on: RunLoop.main)
)
```

### Example: Using `@State` to become first responder on view appear

```swift
struct ExampleView: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var emailFirstResponderDemand: FirstResponderDemand? = .shouldBecomeFirstResponder

  var body: some View {
    VStack {
      /// This field will become first responder automatically
      ResponsiveTextField(
          placeholder: "Email address",
          text: $email,
          firstResponderDemand: $emailFirstResponderDemand
      )
    }
  }
}
```

You could also trigger the field to become first responder after a short
delay after appearing:

```swift
struct ExampleView: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var emailFirstResponderDemand: FirstResponderDemand?

  var body: some View {
    VStack {
      /// This field will become first responder automatically
      ResponsiveTextField(
          placeholder: "Email address",
          text: $email,
          firstResponderDemand: $emailFirstResponderDemand
      )
    }
  }
}
.onAppear {
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    emailFirstResponderDemand = .shouldBecomeFirstResponder
  }
}
```

You could also use the built-in keyboard handling closure to move from one
field to the next when the keyboard return button is tapped:

```swift
struct ExampleView: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var emailFirstResponderDemand: FirstResponderDemand? = .shouldBecomeFirstResponder
  @State var passwordFirstResponderDemand: FirstResponderDemand?

  var body: some View {
    VStack {
      /// Tapping return will make the password field first responder
      ResponsiveTextField(
          placeholder: "Email address",
          text: $email,
          firstResponderDemand: $emailFirstResponderDemand,
          configuration: .emailField,
          handleReturn: { passwordFirstResponderDemand = .shouldBecomeFirstResponder }
      )
      /// Tapping return will resign first responder and hide the keyboard
      ResponsiveTextField(
          placeholder: "Password",
          text: $password,
          firstResponderDemand: $passwordFirstResponderDemand,
          configuration: .passwordField,
          handleReturn: { passwordFirstResponderDemand = .shouldResignFirstResponder }
      )
    }
  }
}
```

When using programatic responder state demands and the `canBecomeFirstResponder`
and `canResignFirstResponder` closures on `FirstResponderStateChangeHandler`,
its important to note that the latter will take priority. If either of these
closures return `false`, the demand will be ignored and marked as fulfilled,
resetting it back to `nil`.

## Licence

This library is released under the Apache v2.0 licence. See [LICENCE](LICENCE)
for details.
