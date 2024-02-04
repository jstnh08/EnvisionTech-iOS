//
//  CourseView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 1/3/24.
//

import SwiftUI

struct CourseView: View {
    var body: some View {
        let videos = ["What is Software?", "Examples of Applications", "Operating Systems", "Programming Languages"]
        
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(Array(videos.enumerated()), id: \.offset) { i, video in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                        .frame(height: 100)
                                    
                                    HStack {
                                        NavigationLink(destination: VideoView() ) {
                                            Image(systemName: "play.fill")
                                                .font(.title2)
                                                .shadow(radius: 10)
                                                .foregroundStyle(.white)
                                                .padding(20)
                                                .background(
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [.blue, .blue.opacity(0.5)]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing)
                                                        )
                                                )
                                                .padding(.trailing, 10)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("Lesson \(i+1)")
                                                .font(.headline.smallCaps())
                                                .foregroundStyle(.gray.opacity(0.5))
                                            
                                            Text(video)
                                                .bold()
                                                .font(.title3)
                                        }
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                                .clipped()
                                .shadow(radius: 2, x: 4, y: 4)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                } header: {
                    VStack {
                        VStack(spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Software and Applications")
                                        .font(.body.smallCaps())
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    Text("Fundamentals of Software")
                                        .bold()
                                        .font(.title)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "wrench.and.screwdriver")
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
            }
        }
    }
}

#Preview {
    CourseView()
}
