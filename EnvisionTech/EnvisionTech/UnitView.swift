//
//  UnitView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/2/23.
//

import SwiftUI

struct TopView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    var unit: UnitBody
    var index: Int
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: VideoView()) {
                VStack {
                    HStack {
                        Image(systemName: unit.icon)
                            .font(.title2)
                        
                        Text("\(unit.name)")
                            .font(.title3)
                            .bold()
                            .fontDesign(.rounded)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                    }
                    
                    HStack{
                        let value = Float(9-index+1)/10.0
                        Text("\(Int(value*100))%")
                            .bold()
                            .font(.subheadline)
                        
                        ProgressView(value: value)
                            .tint(Color("\(currtheme)-symbol"))
                    }
                }
                .foregroundStyle(Color("\(currtheme)-buttonText"))
                .padding()
                .foregroundStyle(.white)
                .background(Color("\(currtheme)-button"))
                .clipShape(.rect(topLeadingRadius: 10, topTrailingRadius: 10))
//                .background(Color("\(currtheme)-background"))
            }
        }
    }
}

struct BottomView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    var body: some View {
        VStack (spacing: 0) {
            Divider()
                .overlay(RoundedRectangle(cornerRadius: 25).fill(.white))
                .padding(.horizontal)
            
            let videos = ["What is Software?", "Examples of Applications", "Operating Systems"]
            
            VStack(spacing: 5) {
                ForEach(Array(videos.enumerated()), id: \.offset) { offset, video in
                    Text("      \(String(offset+1)). \(video)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(2.5)
                }
            }
            .padding(.vertical)
        }
        .background(Color("\(currtheme)-button"))
        .foregroundStyle(Color("\(currtheme)-buttonText").opacity(0.7))
        .clipShape(.rect(bottomLeadingRadius: 10, bottomTrailingRadius: 10))
    }
}


struct UnitView: View {
    @State var units: [UnitBody] = []
    @AppStorage("theme") var currtheme: String = "Light"

    var body: some View {
        NavigationStack {
            Section {
                let unitSpacing: CGFloat = 35
                VStack {
                    ScrollView {
                        VStack(spacing: unitSpacing)  {
                            ForEach(Array(units.enumerated()), id: \.offset) { index, unit in
                                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                    Section {
                                        BottomView()
                                    } header: {
                                        TopView(unit: unit, index: index)
                                    }
                                    .padding(.horizontal)
                                }
                                .clipped()
                                .shadow(color: Color("\(currtheme)-shadow"), radius: 2.0, x: 2, y: 2)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal)
                .padding(.top, unitSpacing)
                .background(Color("\(currtheme)-background"))
                
            } header: {
                HStack {
                    Label {
                        Text("Software & Applications")
                            .font(.title2)
                            .bold()
                    } icon: {
                        Image(systemName: "network")
                            .font(.title2)
                    }
                }
                .foregroundStyle(Color("\(currtheme)-buttonText"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("\(currtheme)-button"))
                .padding(.bottom, -8)
            }
            .task({
                if units.isEmpty {
                    fetchUnits()
                }
            })
        }
    }
    
    func fetchUnits(){
        guard let url = URL(string: "http://192.168.0.134:5000/units") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { return }
            
            guard let data = data else { return }
            
            guard let decodedData = try? JSONDecoder().decode([UnitBody].self, from: data) else { return }
            
            decodedData.forEach { unit in
                units.append(unit)
            }
            
        }.resume()
    }
}

struct UnitBody: Decodable {
    var name: String
    var icon: String
}

#Preview {
    UnitView()
}
