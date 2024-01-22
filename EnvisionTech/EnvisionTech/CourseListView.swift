//
//  CourseListView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 1/17/24.
//

import SwiftUI

struct CourseListView: View {
    @State private var courses: [CourseBody] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15, pinnedViews: .sectionHeaders) {
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("All Courses")
                                .font(.title)
                                .bold()
                            
                            ForEach(courses, id: \.name) { course in
                                NavigationLink(destination: UnitView()) {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(.white)
                                        .frame(height: 110)
                                        .shadow(radius: 3, x: 3, y: 3)
                                        .overlay(
                                            HStack(alignment: .center, spacing: 15) {
                                                Image(systemName: course.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 50, height: 50)
                                                    .shadow(radius: 1)
                                                
                                                VStack(alignment: .leading) {
                                                    Text(course.name)
                                                        .font(.title2)
                                                        .bold()
                                                    
                                                    Text("9 units")
                                                        .font(.body.smallCaps())
                                                }
                                                
                                                Spacer()
                                                
                                                ZStack {
                                                    Circle()
                                                        .stroke(.gray.opacity(0.3), lineWidth: 5)
                                                        .frame(width: 50)
                                                        .overlay(
                                                            Circle()
                                                                .trim(from: 0, to: 0.35)
                                                                .rotation(.degrees(270))
                                                                .stroke(.blue.opacity(0.6), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                                        )
                                                    
                                                    Text("35")
                                                        .font(.subheadline)
                                                        .bold() +
                                                    Text("%")
                                                        .font(.caption2)
                                                }
                                                .padding(.trailing)
                                            }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(.blue.opacity(0.6))
                                                .padding()
                                                .padding(.horizontal)
                                        )
                                }
                            }
                        }
                        .padding()
                    } header: {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Featured Course")
                                .font(.largeTitle)
                                .bold()
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 80/255, green: 145/255, blue: 245/255))
                                .frame(height: 165)
                                .shadow(radius: 3, x: 3, y: 3)
                                .overlay(
                                    HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 7.5) {
                                            Text("Game Dev")
                                                .font(.title)
                                                .bold()
                                            
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(.gray.opacity(0.6))
                                                    .frame(width: 175, height: 5)
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(.white.opacity(0.7))
                                                    .frame(width: 175*0.25, height: 5)
                                            }
                                            
                                            
                                            Text("Explore how your favorite games are created!")
                                                .padding(.top, 7)
                                                .font(.callout)
                                                .italic()
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "gamecontroller.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 110)
                                    }
                                        .frame(maxHeight: .infinity, alignment: .center)
                                        .padding()
                                        .padding(.vertical, 10)
                                        .foregroundStyle(.white)
                                )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding([.horizontal, .top])
                        .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                    }
                }
            }
            .padding(.top, 1)
            .scrollIndicators(.hidden)
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            .task {
                let result: Result<[CourseBody], WebError> = await WebScraperService.shared.handleErrors(
                    task: {
                        try await WebScraperService.shared.fetchComments(route: "courses", accessToken: nil)
                    }
                )
                switch result {
                case .success(let value):
                    courses = value
                case .failure( _):
                    return
                }
            }
        }
    }
}

struct CourseBody: Decodable {
    var name: String
    var icon: String
}

#Preview {
    CourseListView()
}
