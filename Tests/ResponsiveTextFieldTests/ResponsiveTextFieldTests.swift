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
    func testEmptyTextField() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant(""),
                isEditing: .constant(true),
                isSecure: false,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    func testTextFieldWithText() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isEditing: .constant(true),
                isSecure: false,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    func testSecureTextEntry() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("ssh this is top secret"),
                isEditing: .constant(true),
                isSecure: true,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    func testTextFieldCustomTextStyle() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isEditing: .constant(true),
                isSecure: false,
                configuration: .empty
            )
            .responsiveTextFieldFont(.preferredFont(forTextStyle: .headline))
            .responsiveTextFieldTextColor(.systemGreen)
            .padding(),
            as: .fixedSizeTextFieldImage
        )
    }

    func testTextFieldCustomTextAlignment() {
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isEditing: .constant(true),
                isSecure: false,
                configuration: .empty
            )
            .responsiveTextFieldTextAlignment(.center)
            .padding(),
            as: .fixedSizeTextFieldImage,
            named: "Center"
        )
        assertSnapshot(
            matching: ResponsiveTextField(
                placeholder: "Placeholder Text",
                text: .constant("Textfield with some text"),
                isEditing: .constant(true),
                isSecure: false,
                configuration: .empty
            )
            .responsiveTextFieldTextAlignment(.right)
            .padding(),
            as: .fixedSizeTextFieldImage,
            named: "Right"
        )
    }
}
