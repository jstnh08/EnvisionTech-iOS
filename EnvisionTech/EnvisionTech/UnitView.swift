//
//  UnitView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/2/23.
//

import SwiftUI


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
                        VStack(spacing: 0) {
                            ForEach(Array(units.enumerated()), id: \.offset) { i, unit in
                                HStack {
                                    VStack(spacing: 0) {
                                        Rectangle()
                                            .fill(i == 0 ? .clear : .gray.opacity(0.5))
                                            .frame(width: 1.5)

                                        Circle()
                                            .fill(.blue.opacity(0.8))
                                            .frame(width: 35, height: 35)
                                            .shadow(radius: 5)
                                            .overlay(
                                                Text("\(i+1)")
                                                    .foregroundStyle(.white)
                                                    .bold()
                                            )
                                            .padding(.vertical, 2)
                                        
                                        Rectangle()
                                            .fill(i == videos.count-1 ? .clear : .gray.opacity(0.5))
                                            .frame(width: 1.5)
                                    }
                                    
                                    NavigationLink(destination: CourseView()) {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(.white)
                                            .frame(height: 160)
                                            .shadow(radius: 2, x: 2, y: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(.gray, lineWidth: 1)
                                            )
                                            .overlay(
                                                ZStack(alignment: .bottomTrailing) {
                                                    VStack(alignment: .leading) {
                                                        Text(unit.name)
                                                            .multilineTextAlignment(.leading)
                                                            .bold()
                                                            .font(.title2)
                                                            .foregroundStyle(.black)
                                                        
                                                        Text("6 videos")
                                                            .foregroundStyle(.gray.opacity(0.8))
                                                            .font(.body.smallCaps())
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                    
                                                    Image(systemName: "wrench.and.screwdriver")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 50)
                                                        .foregroundStyle(.blue.opacity(0.6))
                                                }
                                                    .padding()
                                                    .padding()
                                            )
                                            .padding()
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.leading)
                            }
                        }
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
        guard let url = URL(string: "http://192.168.0.137:5000/units") else {
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
