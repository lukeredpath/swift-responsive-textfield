//
//  ContentView.swift
//  TextField
//
//  Created by Luke Redpath on 14/03/2021.
//

import ResponsiveTextField
import SwiftUI
import Combine

struct ContentView: View {
    @State
    var email: String = ""

    @State
    var password: String = ""

    @State
    var emailResponderDemand: FirstResponderDemand? = .shouldBecomeFirstResponder

    @State
    var isEmailFirstResponder: Bool = false

    @State
    var passwordResponderDemand: FirstResponderDemand?

    @State
    var isPasswordFirstResponder: Bool = false

    @State
    var isEnabled: Bool = true

    @State
    var hidePassword: Bool = true

    var isEditingEmail: Binding<Bool> {
        Binding(
            get: { isEmailFirstResponder },
            set: {
                emailResponderDemand = $0
                    ? .shouldBecomeFirstResponder
                    : .shouldResignFirstResponder
            }
        )
    }

    var isEditingPassword: Binding<Bool> {
        Binding(
            get: { isPasswordFirstResponder },
            set: {
                passwordResponderDemand = $0
                    ? .shouldBecomeFirstResponder
                    : .shouldResignFirstResponder
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                ResponsiveTextField(
                    placeholder: "Email address",
                    text: $email,
                    firstResponderDemand: $emailResponderDemand.animation(),
                    configuration: .email,
                    onFirstResponderStateChanged: FirstResponderStateChangeHandler(
                        handleStateChange: { isEmailFirstResponder = $0 },
                        canBecomeFirstResponder: { true },
                        canResignFirstResponder: { true }
                    ).animation(),
                    handleReturn: { passwordResponderDemand = .shouldBecomeFirstResponder },
                    supportedStandardEditActions: [],
                    standardEditActionHandler: .init(
                        paste: { _, _ in
                            return false
                        }
                    )
                )
                .responsiveKeyboardReturnType(.next)
                .responsiveTextFieldTextColor(.blue)
                .fixedSize(horizontal: false, vertical: true)
                .disabled(!isEnabled)
                .padding(.bottom)

                HStack(alignment: .center) {
                    ResponsiveTextField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: hidePassword,
                        firstResponderDemand: $passwordResponderDemand.animation(),
                        configuration: .combine(.password, .lastOfChain),
                        onFirstResponderStateChanged: FirstResponderStateChangeHandler { isFirstResponder in
                            isPasswordFirstResponder = isFirstResponder
                        }.animation(),
                        handleReturn: { passwordResponderDemand = .shouldResignFirstResponder },
                        handleDelete: {
                            if $0.isEmpty {
                                emailResponderDemand = .shouldBecomeFirstResponder
                            }
                        }
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .disabled(!isEnabled)

                    Button(action: { withAnimation { hidePassword.toggle() } }) {
                        Image(systemName: hidePassword ? "eye" : "eye.slash")
                            .foregroundColor(hidePassword ? .gray : .blue)
                            .frame(height: 30)
                            .padding(2)
                    }
                }
                .padding(.bottom)

                Toggle("Editing Email?", isOn: isEditingEmail)
                    .padding(.bottom)

                Toggle("Editing Password?", isOn: isEditingPassword)
                    .padding(.bottom)

                Toggle("Hide Password?", isOn: $hidePassword)
                    .padding(.bottom)

                Toggle("Enabled?", isOn: $isEnabled)
                    .padding(.bottom)

                Text("You typed the following email:")
                    .padding(.bottom)

                Text(email).font(.caption)
            }
            .navigationBarTitle("Responsive Text Field Demo")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
