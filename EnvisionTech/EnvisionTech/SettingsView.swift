//
//  SettingsView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/15/23.
//

import SwiftUI

struct SettingsRowView: View {
    var name: String
    var systemName: String


    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                Text("")
                    .padding(.trailing, -15)
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 22)
                    .fontWeight(.semibold)
                Text(name)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.black.opacity(0.65))
        }
        .padding(.vertical, 8)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    let rows = [
                        ["Appearance", "paintbrush"],
                        ["Privacy & Security", "lock"],
                        ["About Us", "questionmark.circle"]
                    ]
                    
                    List {
                        ForEach(rows, id: \.self) { row in
                            NavigationLink(destination: About()) {
                                SettingsRowView(name: row[0], systemName: row[1])
                            }
                            .listRowBackground(Color(red: 240/255, green: 240/255, blue: 240/255))
                        }
                    }
                    .listStyle(.plain)
                } header: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Justin's Settings")
                            .font(.title)
                            .bold()
                        
                        Text("Update your profile or change app settings")
                            .foregroundStyle(.gray.opacity(0.9))
                        
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .horizontal])
                }
                .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            }
        }
    }
}

#Preview {
    SettingsView()
}
