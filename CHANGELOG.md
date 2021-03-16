# Changelog

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
