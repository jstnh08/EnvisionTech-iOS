//
//  ContentView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            
            Button("Register") {
                registerUser()
            }
        }
        .padding()
    }
    
    func registerUser() {
        guard let url = URL(string: "http://127.0.0.1:5000/register") else {
            return
        }
        
        let parameters = ["username": username, "password": password] 
        
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("Status code: \(statusCode)")
            }
        }.resume()
    }
}


#Preview {
    ContentView()
}
