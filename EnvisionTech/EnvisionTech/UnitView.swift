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


struct UnitBlock: View {
    var video: String
    var index: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .frame(width: 165, height: 145)
                .overlay(
                    VStack {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundStyle(.blue.opacity(0.6))
                            .font(.largeTitle)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding()
                        
                        Text("\(video)")
                            .bold()
                            .lineLimit(1)
                            .foregroundStyle(.black)
                    }
                        .padding(.vertical, 25)
                        .frame(maxHeight: .infinity)
                )
                .clipped()
                .shadow(radius: 3, x: 2, y: 2)
            
            Circle()
                .fill(.blue.opacity(0.6))
                .frame(width: 20, height: 20)
                .padding()
                .overlay(
                    Text("\(index+1)")
                        .bold()
                        .font(.footnote)
                        .foregroundStyle(.white)
                )
        }
        .padding(5)
    }
}
struct UnitView: View {
    @State var units: [UnitBody] = []
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State private var showingComments = false

    func actionImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title2)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    let videos = ["Fundamentals", "Productivity","Web Tools","Organization","Mobile Builds"] // abridged names
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 15) {
                                ForEach(Array(videos.enumerated()), id: \.offset) { i, value in
                                    NavigationLink(destination: CourseView()) {
                                        UnitBlock(video: value, index: i)
                                    }
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .padding()
                        .frame(maxHeight: .infinity)
                        .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                    }
                    .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                } header: {
                    VStack {
                        VStack(spacing: 10) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Computer Science Course")
                                        .font(.body.smallCaps())
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    Text("Software and Applications")
                                        .bold()
                                        .font(.title)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "laptopcomputer")
                                    .font(.system(size: 80, weight: .ultraLight))
                            }
                            
                            HStack {
                                Text("60%")
                                    .bold()
                                ProgressView(value: 0.6)
                                    .tint(.white)
                            }
                        }
                        .padding()
                        .foregroundStyle(.white)
                        
                        
                    }
                    .shadow(radius: 5)
                    .padding()
                    .background(.blue.opacity(0.7))
                }
                .task({
                    if units.isEmpty {
                        fetchUnits()
                    }
                })
            }
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
}

#Preview {
    UnitView()
}
