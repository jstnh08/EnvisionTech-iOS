//
//  SettingsView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/15/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    
    func createButton(name: String) -> some View {
        return Button(action: {
            currtheme = name
        }) {
            Text(name)
                .font(.headline)
                .padding(23)
                .background(Color("\(name)-background"))
                .foregroundColor(Color("\(name)-plainText"))
                .cornerRadius(10)
                .shadow(color: name == "Dark" ? .white : .black, radius: 3)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    var body: some View {
        Section {
            VStack {
                Text("Theme")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundStyle(Color("\(currtheme)-plainText"))
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                
                HStack(spacing: 15) {
                    createButton(name: "Light")
                    createButton(name: "Dark")
                    createButton(name: "Maroon")
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color("\(currtheme)-background"))
             
        } header: {
            HStack {
                Text("Settings")
                    .font(.title2)
                    .bold()
            }
            .foregroundStyle(Color("\(currtheme)-buttonText"))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("\(currtheme)-button"))
            .padding(.bottom, -8)
        }
    }
}

#Preview {
    SettingsView()
}
