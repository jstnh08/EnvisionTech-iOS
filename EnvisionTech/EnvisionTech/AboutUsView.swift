//
//  AboutUsView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 1/13/24.
//

import SwiftUI

func accentLine() -> some View {
    Rectangle()
        .fill(.blue.opacity(0.9))
        .frame(width: 40, height: 8)
        .padding(.top, -5)
}

struct SheetView: View {
    @Binding var currentSelection: CoFounderBody?
    @State var member: CoFounderBody
    
    struct CircularImage: View {
        var systemName: String
        var activity: String
        
        var body: some View {
            VStack{
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.8))
                    )
                Text(activity)
                    .foregroundStyle(.black)
                    .bold()
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(member.name)
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 300)
                .clipShape(Rectangle())
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .bottom, endPoint: .top))
                        .opacity(0.5)
                )
                .overlay(
                    Button(action: {currentSelection = nil}) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding()
                    }
                )
                .overlay(
                    Text(member.name)
                        .font(.largeTitle)
                        .padding(.leading)
                        .padding(.bottom, 5)
                        .bold()
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                )
            
            Text(member.position)
                .font(.title3.lowercaseSmallCaps())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top, 5)
            
            accentLine()
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(member.description)
                .padding()
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 7) {
                ForEach(member.info, id: \.text) { info in
                    InfoLabel(systemName: info.icon, text: info.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .foregroundStyle(.black.opacity(0.8))
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(red: 240/255, green: 240/255, blue: 240/255))
    }
    
    struct InfoLabel: View {
        var systemName: String
        var text: String

        var body: some View {
            Label {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.5))
            } icon: {
                Image(systemName: systemName)
                    .foregroundColor(.blue)
                    .imageScale(.large)
            }
            .padding(.horizontal, 5)
        }
    }
}

struct About: View {
    @State private var currentSelection: CoFounderBody? = nil
    @State private var cofounders: [CoFounderBody] = []
    
    func aboutText(_ text: String) -> some View {
        Text(text)
            .lineSpacing(6)
    }
    
    func aboutTitle(_ text: String) -> some View {
        Text(text)
            .font(.title)
            .fontWeight(.bold)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 15) {
                    aboutTitle("Our Mission")
                    accentLine()
                    
                    aboutText("At EnvisionTech, we're on a mission to foster digital literacy in our community, one class at a time. We believe that everyone deserves a free, quality, education and we're here to deliver them one.")
                    
                    aboutText("Our expert instructors are all highly knowledgeable in the sectors that they teach, whether that be computer science, mathematics, or general computer skills.")
                        .padding(.bottom, 20)
                    
                    aboutTitle("Meet the Team")
                    accentLine()
                }
                .foregroundStyle(.black.opacity(0.8))
                .padding([.top, .horizontal])
                .padding(.horizontal)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 60) {
                        ForEach(Array(cofounders.enumerated()), id: \.offset) { i, cofounder in
                            Button(action: {
                                currentSelection = cofounder
                            }) {
                                Image(cofounder.name)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 150)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 25)
                                    )
                                    .overlay(
                                        ZStack(alignment: .bottomLeading) {
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .bottom, endPoint: .top))
                                                .opacity(0.5)
                                            
                                            VStack(alignment: .leading) {
                                                Text("\(cofounder.name)")
                                                    .bold()
                                                
                                                Text(cofounder.position.split(separator: "and")[0])
                                                    .font(.footnote.smallCaps())
                                            }
                                            .padding(.leading)
                                            .padding(.bottom, 5)
                                            .foregroundStyle(.white)
                                        }
                                    )
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.25 : 1.0)
                                    }
                                    .sheet(
                                        isPresented: Binding<Bool>(
                                            get: { currentSelection == cofounder },
                                            set: {_ in }
                                        ),
                                        onDismiss: { currentSelection = nil }
                                    ) {
                                        SheetView(currentSelection: $currentSelection, member: cofounder)
                                    }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 57.5)
                .frame(height: 200)
                
                Spacer()
                                
                let socials = ["youtube", "instagram", "discord"]
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        ForEach(socials, id: \.self) { social in
                            SocialMediaButton(image: Image(social))
                        }
                        SocialMediaButton(image: Image(systemName: "globe"))
                        
                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .bottom])
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
        }
        .task({
            if cofounders.isEmpty {
                fetchAbout()
            }
        })
        .frame(maxHeight: .infinity)
    }
    
    struct SocialMediaButton: View {
        var image: Image
        
        var body: some View {
            Button(action: {
                
            }) {
                Circle()
                    .fill(.blue.opacity(0.8))
                    .frame(width: 55, height: 55)
                    .overlay(
                        image
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .padding(13)
                            .shadow(radius: 5)

                    )
                    .clipped()
                    .shadow(radius: 1)
            }
        }
    }
    
    func fetchAbout() {
        guard let url = URL(string: "http://127.0.0.1:5000/about") else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, error == nil, let decodedData = try? JSONDecoder().decode([CoFounderBody].self, from: data) {
                DispatchQueue.main.async {
                    self.cofounders = decodedData
                }
            }
        }.resume()
    }
}

struct CoFounderBody: Decodable, Equatable {
    var name: String
    var position: String
    var description: String
    
    var likes: [LikesBody]
    struct LikesBody: Decodable {
        var name: String
        var icon: String
    }
    
    var info: [InfoBody]
    struct InfoBody: Decodable {
        var icon: String
        var text: String
    }
    
    static func ==(lhs: CoFounderBody, rhs: CoFounderBody) -> Bool {
        return lhs.name == rhs.name
    }
}

#Preview {
    About()
}
