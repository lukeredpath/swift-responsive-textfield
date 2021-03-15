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
    var isEditingEmail: Bool = true

    @State
    var isEditingPassword: Bool = false

    @State
    var isEnabled: Bool = true

    @State
    var hidePassword: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                ResponsiveTextField(
                    placeholder: "Email address",
                    text: $email,
                    isEditing: $isEditingEmail.animation(),
                    configuration: .email,
                    handleReturn: { isEditingPassword = true }
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
                        isEditing: $isEditingPassword.animation(),
                        isSecure: hidePassword,
                        configuration: .combine(.password, .lastOfChain),
                        handleReturn: { isEditingPassword = false },
                        handleDelete: { isEditingEmail = $0.isEmpty }
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

                Toggle("Editing Email?", isOn: $isEditingEmail)
                    .padding(.bottom)

                Toggle("Editing Password?", isOn: $isEditingPassword)
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
