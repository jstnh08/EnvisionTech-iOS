//
//  HomePageView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 1/17/24.
//

import SwiftUI

struct HomePageView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    @State var courses: [CourseBody] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Courses")
                            .bold()
                            .font(.title)

                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(0..<5) { i in
                                    let x: CGFloat = 260
                                    let y: CGFloat = 250
                                    
                                    NavigationLink(destination: UnitView()) {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                                            .frame(width: x, height: y)
                                            .shadow(radius: 1, x: 2, y: 2)
                                            .overlay(
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 25.0)
                                                        .stroke(.gray, lineWidth: 1)
                                                        .frame(width: x, height: y)
                    
                                                    VStack(alignment: .leading, spacing: 15){
                                                        Image("pythonn")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 100)
                                                            .shadow(radius: 1)
                    
                    
                                                        VStack(alignment: .leading, spacing: 0) {
                                                            Text("Python")
                                                                .font(.title2)
                                                                .fontWeight(.semibold)
                    
                                                            Text("9 Units")
                                                                .font(.body.smallCaps())
                                                        }
                                                    }
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                        .padding(25)
                                                }
                                                    .foregroundStyle(.black)
                                            )
                                            .padding()
                                    }
                                }
                            }
                            .frame(height: 280)
                        }
                        .padding(-15)
                        .scrollIndicators(.hidden)
                        
                        Text("EnvisionTech Blog")
                            .bold()
                            .font(.title)
                        
                        HStack {
                            NavigationLink(destination: BlogView()) {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                                    .frame(width: 100, height: 100)
                                    .shadow(radius: 1, x: 2, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(.gray)
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "newspaper")
                                                    .resizable()
                                                    .foregroundStyle(.blue.opacity(0.8))
                                                    .aspectRatio(contentMode: .fit)
                                                    .padding(27)
                                            )
                                        )
                            }
                                                        
                            VStack(alignment: .leading) {
                                Text("Latest Blog Post")
                                    .foregroundStyle(.gray)
                                    .font(.callout.smallCaps())
                                Text("EnvisionTech: More Than an App")
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                                
                                Text("Dec. 24, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .foregroundStyle(.black)
                            .padding(5)
                        }
                        .frame(height: 100)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } header: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome back, Justin!")
                            .font(.title)
                            .bold()
                        
                        HStack(spacing: 0) {
                            Text("Explore the app or ")
                                .foregroundStyle(.gray.opacity(0.9))
                            
                            NavigationLink(destination: VideoView()) {
                                Text("jump back in")
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            }
        }
    }
}



#Preview {
    HomePageView()
}
