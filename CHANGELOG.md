# Changelog

## 0.7.0

* Replace hardcoded dependency on RunLoop.main to an environment-controlled scheduler.

## 0.6.0

### Fixed

* Ensure text field responder state changes always happen on the next runloop tick to avoid attribute graph cycles in Xcode 13.
* Added improvements to support dynamic type.

## 0.5.2

### Fixed

* Ensure responder demand is reset on the next runloop tick to avoid a runtime
error due to a nested state update.
* Workaround for what seems to be a compiler or xccov bug that causes coverage
data to become malformed when passing a reference to a super implementation
in a point-free manner.

## 0.5.1

### Fixed

* Bug where `shouldUpdateViews` was not getting reset correctly when first responder demand
was fulfilled.
* `FirstResponderStateChangeHandler.receive(on:)` operator was not passing it's `options`
to the scheduler.
* Fixed a bug in standard edit action handling where the original implementation would not get
called if a standard edit action handling value was given but no override for the specific edit action
existed.
* README and documentation fixes.

## 0.5.0

### Changed

* Added `FirstResponderStateChangeHandler.receive(on:)` to allow change handlers
to be called on a specfic scheduler to avoid nested view updates.
* Added an `animation:` parameter to the `FirstResponderStateChangeHandler.animation()`
modifier so you can provide a custom animation, or disable animations explicitly.

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
