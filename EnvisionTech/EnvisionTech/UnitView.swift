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
                            .font(.title3)
                        
                        Text("\(index+1): \(unit.name)")
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
                .background(Color("\(currtheme)-button"))
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        topTrailingRadius: 20
                    )
                )
                .background(.clear)
                .foregroundStyle(.white)
            }
        }
    }
}

struct BottomView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    var body: some View {
        VStack (spacing: 5) {
            let videos = ["What is Software?", "Examples of Applications", "Operating Systems"]
            ForEach(Array(videos.enumerated()), id: \.offset) { offset, video in
                Text("      \(String(offset+1)). \(video)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(2.5)
            }
        }
        .padding(.vertical)
        .background(Color("\(currtheme)-button").opacity(0.2))
        .foregroundStyle(Color("\(currtheme)-plainText"))
        .clipShape(
            .rect(
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20
            )
        )
    }
}


struct UnitView: View {
    @State var units: [UnitBody] = []
    @AppStorage("theme") var currtheme: String = "Light"

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "network")
                        .font(.title2)

                    Text("Software & Applications")
                        .font(.title2)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .padding(.bottom, 30)
                
                ScrollView {
                    LazyVStack(spacing: 35, pinnedViews: .sectionHeaders) {
                        ForEach(Array(units.enumerated()), id: \.offset) { index, unit in
                            Section {
                                BottomView()
                                    .padding(.top, -35)
                            } header: {
                                TopView(unit: unit, index: index)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
            .background(Color("\(currtheme)-background"))
            .task({
                if units.isEmpty {
                    fetchUnits()
                }
            })
        }
    }
    
    func fetchUnits(){
        guard let url = URL(string: "http://192.168.0.132:5000/units") else {
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
