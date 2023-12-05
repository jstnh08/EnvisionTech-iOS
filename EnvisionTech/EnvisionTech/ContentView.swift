//
//  ContentView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var grade = 5.0
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var gradeNames: [Double: String] = [
        0.0: "Kindergarten", 1.0: "1st Grade", 2.0: "2nd Grade", 3.0: "3rd Grade"
    ]
    private var courses = [
        ["Web Safety", "lock.shield.fill"],
        ["Coding", "externaldrive.fill"],
        ["Game Dev", "gamecontroller.fill"],
        ["Software", "network"],
        ["Computers", "desktopcomputer"]
    ]
    
    @State private var selected = ["Web Safety"]
    
    func change(name: String) {
        if let index = selected.firstIndex(of: name) {
            selected.remove(at: index)
        }
        else {
            selected.append(name)
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20){
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                Text("EnvisionTech")
                    .font(.largeTitle)
                    .bold()
            }
            
            Form {
                Section(header: Text("Personal Information").foregroundStyle(.white)){
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("User Information").foregroundStyle(.white)){
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                }
                
            }
            
            .frame(height: 340)
            .scrollContentBackground(.hidden)
            .environment(\.colorScheme, .light)
            
            let gradeName = grade > 3 ? "\(Int(grade))th Grade" : gradeNames[grade]!
            Text(gradeName)
            
            Slider(
                value: $grade,
                in: 0...12,
                step: 1
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Text("K")
            } maximumValueLabel: {
                Text("12")
            }
            .tint(.red)
            
            Text("I'm Interested In..")
                .font(.title2)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<courses.count, id: \.self) { i in
                        VStack{
                            Button (action: {self.change(name: courses[i][0])}){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 85, height: 85)
                                    Image(systemName: courses[i][1])
                                        .font(.title)
                                        .foregroundStyle(.yellow)
                                }
                                .foregroundStyle(.red)
                                .opacity(selected.contains(courses[i][0]) ? 1.0 : 0.5)
                            }
                            Text(courses[i][0])
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: registerUser) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 50)
                    .overlay(
                        Text("Register")
                            .foregroundStyle(.white)
                            .bold()
                            .fontDesign(.rounded)
                    )
            }
            .alert(
                "Registration Error",
                isPresented: $showingAlert,
                actions: { },
                message: {
                    Text(alertMessage)
                }
            )
        }
        .padding()
        .preferredColorScheme(.dark)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    func checkValid() -> Bool {
        let emailChecker = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
        if firstName.isEmpty || lastName.isEmpty {
            alertMessage = "Please fill out your first and last name"
        }
        else if username.count < 5 {
            alertMessage = "Minimum of 5 characters required for username"
        }
        else if email.firstMatch(of: emailChecker) == nil {
            alertMessage = "Please enter a valid email address"
        }
        else {
            showingAlert = false
            return false
        }
        showingAlert = true
        return true
    }
    
    func registerUser() {
        if checkValid() { return }
        
        guard let url = URL(string: "http://127.0.0.1:5000/register") else {
            return
        }

        let parameters = RegisterParameters(username: username, email: email, password: password, firstName: firstName, lastName: lastName, courses: selected, grade: grade)
        
        guard let postData = try? JSONEncoder().encode(parameters) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else {return}
            
            guard let decodedData = try? JSONDecoder().decode(RegisterResponse.self, from: data) else {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if (200..<300).contains(statusCode){
                    print("Success!")
                }
                else {
                    showingAlert = true
                    alertMessage = decodedData.message
                }
            }
        }.resume()
    }
}

struct RegisterParameters: Codable {
    let username, email, password, firstName, lastName: String
    let courses: [String]
    let grade: Double
}


struct RegisterResponse: Decodable {
    let message: String
}


#Preview {
    ContentView()
}
