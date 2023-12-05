//
//  UnitView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/2/23.
//

import SwiftUI

struct TopView: View {
    var unit: UnitBody
    var index: Int
    
    var body: some View {
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
                        .tint(.yellow)
                }
            }
            .padding()
            .background(.red)
            .clipShape(
                .rect(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
            )
            .background(.black)
            .foregroundStyle(.white)
        }
    }
}

struct BottomView: View {
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
        .background(.red.opacity(0.8))
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
            .preferredColorScheme(.dark)
            .task({
                if units.isEmpty {
                    fetchUnits()
                }
            })
        }
    }
    
    func fetchUnits(){
        guard let url = URL(string: "http://127.0.0.1:5000/units") else {
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
    var activated: Bool
}

#Preview {
    UnitView()
}
