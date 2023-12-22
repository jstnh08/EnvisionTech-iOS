//
//  BlogView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/17/23.
//

import SwiftUI

struct BlogTitle: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .minimumScaleFactor(0.01)
            .lineLimit(2)
            .fontWeight(.bold)
            .fontDesign(.rounded)
//            .multilineTextAlignment(.center)
            .fontWidth(.condensed)
    }
}
struct BlogHeader: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .fontDesign(.rounded)
            .font(.title)
            .fontWeight(.semibold)
            .padding(.top)
    }
}
struct BlogText: View {
    var text: String
    
    init(_ text: String) {
        self.text = "    "+text
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .fontDesign(.rounded)
    }
}

struct BlogDescription: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.01)
            .lineLimit(3)
    }
}

struct BlogView: View {
    @State private var blog: BlogBody? = nil
    @AppStorage("theme") var currTheme: String = "Light"
    @State var currentSelection: CoFounderBody? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if let blog {
                        BlogTitle(blog.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        BlogDescription(blog.description)
                            .padding(.vertical)
                        
                        VStack(alignment: .center, spacing: 15) {
                            Divider()
                                .frame(height: 1.5)
                                .overlay(RoundedRectangle(cornerRadius: 5))
                            
                            (Text("By ") + Text(blog.author.name).foregroundColor(.accentColor))
                                .bold()
                                .onTapGesture {
                                    currentSelection = blog.author
                                }
                                .sheet(
                                    isPresented: Binding<Bool>(
                                        get: { currentSelection == blog.author },
                                        set: {_ in }
                                    ),
                                    onDismiss: { currentSelection = nil }
                                ) {
                                    SheetView(currentSelection: $currentSelection, member: blog.author)
                                }
                            Text("December 17, 2023, EnvisionTech Blog")
                                .fontWeight(.semibold)
                            
                            Divider()
                                .frame(height: 1.5)
                                .overlay(RoundedRectangle(cornerRadius: 5))
                        }
                        
                        ForEach(blog.sections, id: \.header) { section in
                            BlogHeader(section.header)
                            ForEach(section.paragraphs, id: \.self) { paragraph in
                                BlogText(paragraph)
                            }
                        }
                    }
                }
                .task({
                    fetchCourses()
                })
                .padding()
                .foregroundStyle(Color("\(currTheme)-plainText"))
                
            }
            .background(Color("\(currTheme)-background"))
            .scrollIndicators(.hidden)
        }
    }
    
    func fetchCourses(){
        guard let url = URL(string: "http://192.168.0.132:5000/blog") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil { return }
            guard let data = data else { return }
            guard let decodedData = try? JSONDecoder().decode(BlogBody.self, from: data) else { return }
            
            self.blog = decodedData
        }.resume()
    }
}

struct BlogBody: Decodable {
    var title: String
    var description: String
    var author: CoFounderBody
    var sections: [SectionBody]
    
    struct SectionBody: Decodable {
        var header: String
        var paragraphs: [String]
    }
}

#Preview {
    BlogView()
}
