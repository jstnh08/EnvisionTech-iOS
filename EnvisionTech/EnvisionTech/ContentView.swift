//
//  ContentView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/25/23.
//

import SwiftUI
import Foundation

class LoginViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    
    @Published var grade = 8.0
    @Published var alertMessage = ""
    
    @Published var revealedSecures: [Focused] = []
    @Published var navigateToHome = false
    
    func checkValid() async {
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
            await registerUser()
        }
    }
    
    func registerUser() async {
        guard let url = URL(string: "http://192.168.0.132:5000/register") else {
            return
        }

        let parameters = RegisterParameters(username: username, email: email, password: password, firstName: firstName, lastName: lastName, grade: grade)
                
        guard let postData = try? JSONEncoder().encode(parameters) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let decodedData = try JSONDecoder().decode(RegisterResponse.self, from: data)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200..<300).contains(httpResponse.statusCode) {
                    navigateToHome = true
                } else {
                    alertMessage = decodedData.message
                }
            }
        } catch {
            print("Error while \(error)")
        }
    }
    
    func checkFieldsFilled() -> Bool {
        return !(firstName.isEmpty || lastName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty)
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
    @AppStorage("theme") var currtheme: String = "Maroon"
    @StateObject var loginModel = LoginViewModel()
    @FocusState private var focusedField: Focused?
        
    func textField(prompt: String, text: Binding<String>, focused: Focused, autoCapitalization: TextInputAutocapitalization,  isSecure: Bool = false, check: () -> Bool = {true}) -> some View {
        Group {
            if isSecure && !loginModel.revealedSecures.contains(focused) {
                SecureField("", text: text, prompt: Text(prompt).foregroundColor(.white))
            } else {
                TextField("", text: text, prompt: Text(prompt).foregroundColor(.white))
            }
        }
        .frame(width: 250, height: 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .focused($focusedField, equals: focused)
        .textInputAutocapitalization(autoCapitalization)
        .autocorrectionDisabled(true)
        .font(.headline)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("\(currtheme)-button"))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(text.wrappedValue.isEmpty ? .clear : check() ? Color("\(currtheme)-symbol") : .gray, lineWidth: 3)
                if isSecure && !text.wrappedValue.isEmpty {
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
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                    }
                }
            }
        )
        .shadow(color: Color("\(currtheme)-shadow"), radius: 4, x: 4, y: 4)
        .onTapGesture {
            focusedField = focused
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationStack {
            Section {
                VStack(spacing: 10) {
                    ScrollView {
                        displayForm()
                        gradeChanger()
                        signUpButton()
                    }
                    .scrollIndicators(.hidden)
                }
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
                .background(Color("\(currtheme)-background"))
            } header: {
                displayHeader()
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    func displayHeader() -> some View {
        HStack {
            HStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 35)
                
                Text("EnvisionTech")
                    .font(.title3)
                    .bold()
                
            }
            .padding(5)
        }
        .foregroundStyle(Color("\(currtheme)-buttonText"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color("\(currtheme)-button"))
        .padding(.bottom, -8)
    }
    
    func displayForm() -> some View {
        VStack(spacing: 10) {
            displayText(text: "Personal Information")
            
            textField(prompt: "First Name", text: $loginModel.firstName, focused: .firstName, autoCapitalization: .words)
            textField(prompt: "Last Name", text: $loginModel.lastName, focused: .lastName, autoCapitalization: .words)
            
            displayText(text: "User Information")
            
            textField(prompt: "Email", text: $loginModel.email, focused: .email, autoCapitalization: .never) {
                let emailChecker = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
                return loginModel.email.firstMatch(of: emailChecker) != nil
            }
            textField(prompt: "Username", text: $loginModel.username, focused: .usernmae, autoCapitalization: .never) {
                return loginModel.username.count >= 3
            }
            textField(prompt: "Password", text: $loginModel.password, focused: .password, autoCapitalization: .never, isSecure: true) {
                return loginModel.password.count >= 5
            }
        }
    }
    
    func displayText(text: String) -> some View {
        Text(text)
            .font(.title)
            .fontDesign(.rounded)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .leading])
            .padding(.bottom, 5)
    }
    
    func gradeChanger() -> some View {
        VStack(spacing: 10) {
            Text(loginModel.getGradeName())
                .font(.title2)
                .padding(.top)
                .bold()
            
            Slider(value: $loginModel.grade, in: 0...12, step: 1 ) {
                Text("Speed")
            } minimumValueLabel: {Text("K")} maximumValueLabel: {Text("12")}
                .padding(.horizontal)
        }
    }
    
    func signUpButton() -> some View {
        Button(action: {
            Task {
                await loginModel.checkValid()
            }
        }) {
            RoundedRectangle(cornerRadius: 50.0)
                .fill(loginModel.checkFieldsFilled() ? Color("\(currtheme)-symbol") : .gray.opacity(0.7))
                .frame(height: 60)
                .padding()
                .overlay(
                    Text("Sign Up")
                        .bold()
                        .font(.title3.lowercaseSmallCaps())
                )
        }
        .shadow(color: loginModel.checkFieldsFilled() ? Color("\(currtheme)-shadow") : .clear, radius: 5, x: 10, y: 10)
        .disabled(!loginModel.checkFieldsFilled())
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
    let username, email, password, firstName, lastName: String
    let grade: Double
}


struct RegisterResponse: Decodable {
    let message: String
}


#Preview {
    ContentView()
}
