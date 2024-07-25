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

    @MainActor
    func testTextFieldInArabic() {
        // Set the locale to Arabic
        setLanguage("ar")

        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "نص العنصر النائب", // Arabic for "Placeholder Text"
                text: .constant(""),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage,
            named: "ArabicEmpty"
        )

        assertSnapshot(
            of: ResponsiveTextField(
                placeholder: "نص العنصر النائب",
                text: .constant("نص في حقل الإدخال"),
                isSecure: false,
                firstResponderDemand: nil,
                configuration: .empty
            ).padding(),
            as: .fixedSizeTextFieldImage,
            named: "ArabicText"
        )

        // Reset to default language
        setLanguage("en")
    }

    @MainActor
    func testTextFieldWithDifferentConfigurations() {
        let configurations: [(ResponsiveTextField.Configuration, String)] = [
            (.empty, "Empty Configuration"),
            (.password, "Password"),
            (.autoclears, "Auto clear"),
            (.email, "Email")
        ]
        
        for (config, name) in configurations {
            assertSnapshot(
                of: ResponsiveTextField(
                    placeholder: "Placeholder Text",
                    text: .constant("Sample text"),
                    isSecure: false,
                    firstResponderDemand: nil,
                    configuration: config
                ).padding(),
                as: .fixedSizeTextFieldImage,
                named: name
            )
        }
    }

    private func setLanguage(_ language: String) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
