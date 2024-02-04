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
    }
}
struct BlogHeader: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .minimumScaleFactor(0.01)
            .lineLimit(1)
            .fontDesign(.rounded)
            .font(.title.lowercaseSmallCaps())
            .fontWeight(.semibold)
            .padding(.top)
    }
}
struct BlogText: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 19))
            .fontDesign(.rounded)
            .lineSpacing(10)
            .padding(.bottom)
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
            .minimumScaleFactor(0.01)
            .lineLimit(3)
            .lineSpacing(10)
    }
}

struct BlogView: View {
    @State private var blog: BlogBody? = nil
    @State var currentSelection: CoFounderBody? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if let blog {
                        BlogTitle(blog.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        BlogDescription(blog.description)
                        
                        Text(blog.author.name).foregroundColor(.blue.opacity(0.6))
                            .bold()
                            .font(.body.smallCaps())
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
                        
                        Divider()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                            )
                        
                        ForEach(blog.sections, id: \.header) { section in
                            BlogHeader(section.header)
                            ForEach(section.paragraphs, id: \.self) { paragraph in
                                BlogText(paragraph)
                            }
                        }
                        
                        Text("Dec. 17, 2023, 9:57 AM PST")
                            .foregroundStyle(.gray.opacity(0.75))
                            .font(.caption)
                    }
                }
                .task({
                    fetchCourses()
                })
                .padding()                
            }
            .padding(.horizontal)
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            .scrollIndicators(.hidden)
        }
    }
    
    func fetchCourses(){
        guard let url = URL(string: "http://192.168.0.137:5000/blog") else {
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
