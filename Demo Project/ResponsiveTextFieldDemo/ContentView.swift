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
    var fullName: String = ""
    
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
                    placeholder: "email_address_label",
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
                .responsiveTextFieldFont(.preferredFont(forTextStyle: .title1))
                .responsiveKeyboardReturnType(.next)
                .responsiveTextFieldTextColor(.blue)
                .fixedSize(horizontal: false, vertical: true)
                .disabled(!isEnabled)
                .padding(.bottom)

                HStack(alignment: .center) {
                    ResponsiveTextField(
                        placeholder: "password_label",
                        text: $password,
                        isSecure: hidePassword,
                        firstResponderDemand: $passwordResponderDemand.animation(),
                        configuration: .combine(.password, .lastOfChain),
                        onFirstResponderStateChanged: FirstResponderStateChangeHandler
                            .updates($isPasswordFirstResponder)
                            .receive(on: RunLoop.main)
                            .animation(),
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
                
                ResponsiveTextField(
                          placeholder: "full_name_label",
                          text: $fullName
                      )
                .responsiveKeyboardReturnType(.next)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)

                Toggle("editing_email_label", isOn: isEditingEmail)
                    .padding(.bottom)

                Toggle("editing_password_label", isOn: isEditingPassword)
                    .padding(.bottom)

                Toggle("hide_password_label", isOn: $hidePassword)
                    .padding(.bottom)

                Toggle("enable_label", isOn: $isEnabled)
                    .padding(.bottom)

                Button("random_password_label") {
                    password = UUID().uuidString
                }

                Text("typed_email_label")
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
