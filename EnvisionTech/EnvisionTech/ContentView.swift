//
//  ContentView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/25/23.
//

import SwiftUI
import Foundation

@MainActor class LoginViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    
    @Published var grade = 8.0
    @Published var alertMessage = ""
    
    @Published var revealedSecures: [Focused] = []
    @Published var navigateToHome = false
    
    @Published var alertError: WebError?
    
    func checkValid() {
        if username.count < 3 {
            alertMessage = "Minimum of 3 characters required for username"
        }
        else if password.count < 5 {
            alertMessage = "Minimum of 5 characters required for password"
        }
        else if email.firstMatch(of: /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/) == nil {
            alertMessage = "Please enter a valid email address"
        }
        else {
            registerUser()
        }
    }
    
    func registerUser() {
        Task {
            let parameters = RegisterParameters(
                username: username, email: email, password: password
            )
            
            let result: Result<RegisterResponse, WebError> = await WebScraperService.shared.handleErrors(task: {
                try await WebScraperService.shared.postComment(
                    route: "register", parameters: parameters, accessToken: nil
                )
            })
            
            switch result {
            case .success(let decodedData):
                setKeychain(decodedData: decodedData)
            case .failure(let error):
                alertMessage = error.error
                alertError = error
            }
        }
    }
    
    func setKeychain(decodedData: RegisterResponse) {
        let service = "com.myapp.envisiontech"
        let account = String(decodedData.id)
        let accessToken = decodedData.accessToken.data(using: .utf8)!
    
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service]

        let attributes: [String: Any] = [kSecAttrAccount as String: account,
                                         kSecValueData as String: accessToken]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrAccount as String: account,
                                        kSecAttrService as String: service,
                                        kSecValueData as String: accessToken]

            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                let errorMessage = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Error"
                print("Failed to add item: \(errorMessage)")
                return
            }
        }
        navigateToHome = true
    }
    
    func checkFieldsFilled() -> Bool {
        return !(username.isEmpty || email.isEmpty || password.isEmpty)
    }
    
    func getGradeName() -> String {
        let gradeNames: [Double: String] = [
            0.0: "Kindergarten", 1.0: "1st Grade", 2.0: "2nd Grade", 3.0: "3rd Grade"
        ]
        return grade > 3 ? "\(Int(grade))th Grade" : gradeNames[grade]!
    }
}

enum Focused: Hashable {
    case firstName
    case lastName
    case usernmae
    case password
    case email
}

struct ContentView: View {
    @StateObject var loginModel = LoginViewModel()
    @FocusState private var focusedField: Focused?
        
    func textField(prompt: String, text: Binding<String>, focused: Focused, autoCapitalization: TextInputAutocapitalization,  isSecure: Bool = false, systemName: String, check: () -> Bool = {true}) -> some View {
        VStack(alignment: .leading, spacing: 5) {
//            Text(prompt)
//                .font(.headline)
//                .fontDesign(.rounded)
//                .foregroundStyle(.blue.opacity(0.6))
            
            Group {
                if isSecure && !loginModel.revealedSecures.contains(focused) {
                    SecureField("", text: text, prompt: Text("Enter \(prompt.lowercased())").foregroundColor(.gray.opacity(0.7)))
                } else {
                    TextField("", text: text, prompt: Text("Enter \(prompt.lowercased())").foregroundColor(.gray.opacity(0.7)))
                }
            }
            .frame(width: 250, height: 22)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading)
            .padding(.leading)
            .focused($focusedField, equals: focused)
            .textInputAutocapitalization(autoCapitalization)
            .autocorrectionDisabled(true)
//            .font(.headline)
            .fontDesign(.rounded)
            .padding()
            .background(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(text.wrappedValue.isEmpty ? .gray.opacity(0.3) : check() ? .blue : .gray, lineWidth: 1.5)
                    
                    Image(systemName: systemName)
                        .frame(width: 50)
                        .foregroundStyle(.gray.opacity(0.7))
                    
                    
                    if isSecure {
                        let index = loginModel.revealedSecures.firstIndex(of: focused)
                        Button (action: {
                            focusedField = focused
                            if let index {
                                loginModel.revealedSecures.remove(at: index)
                            } else {
                                loginModel.revealedSecures.append(focused)
                            }
                        }) {
                            Image(systemName: index != nil ? "eye.slash" : "eye")
                                .foregroundStyle(.gray.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                                .fontWeight(.light)
                        }
                    }
                }
            )
            .onTapGesture {
                focusedField = focused
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationStack {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    displayHeader()
                    
                    ScrollView {
                        displayForm()
                        signUpButton()
                        
                        HStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 5).frame(height: 1)
                            Text("Or").font(.body.smallCaps())
                            RoundedRectangle(cornerRadius: 5).frame(height: 1)
                        }
                        .foregroundStyle(.gray)
                        
                        Button(action: {
                            loginModel.checkValid()
                        }) {
                            RoundedRectangle(cornerRadius: 50.0)
                                .fill(.gray.opacity(0.3))
                                .frame(height: 55)
                                .overlay(
                                    HStack(spacing: 15) {
                                        Image("google")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25)
                                        Text("Continue with Google")
                                            .font(.body.smallCaps())
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color(white: 0.3))
                                    }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal)
                                )
                                .padding()
                        }
                                                
                        NavigationLink(destination: VideoView()) {
                            Text("Have an account?")
                                .fontWeight(.medium)
                                .foregroundStyle(.gray) +
                            Text(" Sign in")
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .onTapGesture {
                focusedField = nil
            }
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
        }
    }
    
    func displayHeader() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Register")
                .foregroundStyle(.blue.opacity(0.8))
                .font(.largeTitle)
                .bold()
            
            Text("Welcome to EnvisionTech, your free virtual teacher")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray.opacity(0.7))
        }
        .padding()
    }
    
    func displayForm() -> some View {
        VStack(spacing: 20) {
            textField(prompt: "Email", text: $loginModel.email, focused: .email, autoCapitalization: .never, systemName: "envelope") {
                let emailChecker = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
                return loginModel.email.firstMatch(of: emailChecker) != nil
            }
            textField(prompt: "Username", text: $loginModel.username, focused: .usernmae, autoCapitalization: .never, systemName: "person") {
                return loginModel.username.count >= 3
            }
            textField(prompt: "Password", text: $loginModel.password, focused: .password, autoCapitalization: .never, isSecure: true, systemName: "lock") {
                return loginModel.password.count >= 5
            }
        }
        .padding(.top, 5)
    }
    
    func displayText(text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontDesign(.rounded)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading])
            .padding(.bottom, 5)
            .foregroundStyle(.blue.opacity(0.7))
    }
    
    func gradeChanger() -> some View {
        VStack(spacing: 10) {
            Text(loginModel.getGradeName())
                .foregroundStyle(.blue.opacity(0.5))
                .font(.title2)
                .padding(.top)
                .bold()
            
            Slider(value: $loginModel.grade, in: 0...12, step: 1 ) {
                Text("Speed")
            } minimumValueLabel: {Text("K")} maximumValueLabel: {Text("12")}
                .tint(.blue.opacity(0.5))
        }
        .padding(.horizontal)
    }
    
    func signUpButton() -> some View {
        Button(action: {
            loginModel.checkValid()
        }) {
            RoundedRectangle(cornerRadius: 50.0)
                .fill(.blue)
                .frame(height: 55)
                .padding()
                .overlay(
                    Text("Sign Up")
                        .bold()
                        .font(.body.smallCaps())
                        .foregroundStyle(.white)
                )
        }
        .clipped()
        .shadow(radius: 2, x: 3, y: 3)
        .alert(
            "Registration Error",
            isPresented: .init(get: {!loginModel.alertMessage.isEmpty}, set: {_ in}),
            actions: {
                Button("OK", action: { loginModel.alertMessage = "" })
            },
            message: {
                Text(loginModel.alertMessage)
            }
        )
        .navigationDestination(isPresented: $loginModel.navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct RegisterParameters: Codable {
    let username, email, password: String
}

struct RegisterResponse: Decodable {
    let accessToken: String
    let id: Int
}

struct User: Codable {
    var id: Int
}

#Preview {
    ContentView()
}
