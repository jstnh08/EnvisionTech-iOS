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
            Section {
                VStack {
//                    Text("Featured Courses")
//                        .foregroundStyle(Color("\(currtheme)-plainText"))
//                        .fontDesign(.rounded)
//                        .font(.title)
//                        .bold()
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(courses, id: \.name) { course in
//                                VStack {
//                                    NavigationLink(destination: UnitView()) {
//                                        RoundedRectangle(cornerRadius: 25.0)
//                                            .aspectRatio(contentMode: .fit)
//                                            .foregroundStyle(Color("\(currtheme)-button"))
//                                            .frame(width: 85, height: 85)
//                                            .overlay(
//                                                Image(systemName: course.icon)
//                                                    .font(.title)
//                                                    .foregroundStyle(Color("\(currtheme)-symbol"))
//                                            )
//                                            .shadow(color: Color("\(currtheme)-shadow"), radius: 2.0, x: 2, y: 2)
//                                    }
//                                    Text(course.name)
//                                        .foregroundStyle(Color("\(currtheme)-plainText"))
//                                        .fontDesign(.rounded)
//                                        .font(.headline)
//                                        .padding(.vertical, 10)
//                                }
//                                .padding(5)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    Text("Jump Back In")
//                        .foregroundStyle(Color("\(currtheme)-plainText"))
//                        .fontDesign(.rounded)
//                        .font(.title)
//                        .bold()
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    let units = [
//                        UnitBody(name: "Software Fundamentals", icon: "puzzlepiece.fill"),
//                        UnitBody(name: "Web Tools", icon: "bubble.right.fill"),
//                    ]
//                    ForEach(Array(units.enumerated()), id: \.offset) { offset, unit in
//                        TopView(unit: unit, index: offset)
//                            .clipShape(.rect(bottomLeadingRadius: 10, bottomTrailingRadius: 10))
//                            .padding(.horizontal)
//                            .padding(.vertical, 10)
//                            .shadow(color: Color("\(currtheme)-shadow"), radius: 2.0, x: 2, y: 2)
//                    }
                }
//                .task({
//                    if courses.isEmpty {
//                        fetchCourses()
//                    }
//                })
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color("\(currtheme)-background"))
            } header: {
                HStack {
                    HStack {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 35)
                        
                        Text("EnvisionTech")
                            .font(.title3)
                            .bold()
                        
                    }
                    .padding(5)
                    
                    Spacer()
                    
                    Image(systemName: "bell.fill")
                        .imageScale(.large)
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                    }
                    
                }
                .foregroundStyle(Color("\(currtheme)-buttonText"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("\(currtheme)-button"))
            }
        }
    }
}



#Preview {
    HomePageView()
}
