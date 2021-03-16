# Changelog

## 0.4.1

### Fixed

* Text field text would not update to reflect external state changes.

## 0.4.0

### Changed

* Replaced `FirstResponderStateChangeHandler` typealias with a real type that
  wraps a change handler closure.
* Replaced `FirstResponderState` with a single boolean value to represent the
  first responder state.

### Added

* The ability to easily update external state when the first responder state
  changes using `FirstResponderStateChangeHandler.updates($someBinding)`.
* Easily animate first responder state changes using the `.animation()` modifier
  on `FirstResponderStateChangeHandler`
* `FirstResponderStateChangeHandler` can also be given closures for custom
  control over whether or not the text field should become or resign first
  responder, hooking into the `shouldBeginEditing` and `shouldEndEditing`
  delegate methods.

## 0.3.0

### Added

* Supported standard edit actions can be customised using the `supportedStandardEditActions`
  parameter when initialising.
* Added the ability to override and customise how standard edit actions are handled
  by providing a `StandardEditActionHandling` value using the `standardEditActionHandler`
  parameter when initialising.

### Changed

* Remove RunLoop tick when updating first responder state.
* Replaced `isEditing` binding with a `firstResponderDemand` binding and an
  `onFirstResponderStateChanged:` callback function.

## 0.2.0

### Added

* Delete key handling.
* Text change handling and prevention.
* Added automatic documentation generation workflow.

## 0.1.0 - 2021-03-14

### Added

* Initial Release.
* Binding-based text handling.
* Binding-based first responder handling.
* Styling view modifiers.
* Secure text entry.
* Return key handling.
* Configuration system.
* Demo project.
