import XCTest
import ResponsiveTextField
import SnapshotTesting
import SwiftUI

extension Snapshotting where Value: View, Format == UIImage {
    static var fixedSizeTextFieldImage: Self {
        .image(layout: .fixed(width: 320, height: 30))
    }
}

final class ResponsiveTextFieldTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .never) {
            super.invokeTest()
        }
    }
    
    @MainActor
    func testEmptyTextField() {
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant(""),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    @MainActor
    func testTextFieldWithText() {
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    @MainActor
    func testSecureTextEntry() {
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("ssh this is top secret"),
                isSecure: true,
                firstResponderDemand: nil,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    @MainActor
    func testTextFieldCustomTextStyle() {
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            )
            .responsiveTextFieldFont(.preferredFont(forTextStyle: .headline))
            .responsiveTextFieldTextColor(.systemGreen)
            .padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    @MainActor
    func testPlaceholderTextFieldWithText() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            )
            .responsiveTextFieldTextColor(UIColor.systemBlue)
            .padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    @MainActor
    func testTextFieldCustomTextAlignment() {
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            )
            .responsiveTextFieldTextAlignment(.center)
            .padding(),
            as: .fixedSizeTextFieldImage,
            named: "Center"
        )
        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            )
            .responsiveTextFieldTextAlignment(.right)
            .padding(),
            as: .fixedSizeTextFieldImage,
            named: "Right"
        )
    }
}
