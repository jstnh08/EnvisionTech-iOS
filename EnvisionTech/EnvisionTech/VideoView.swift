import SwiftUI
import WebKit
import AVKit


struct VideoView: View {
    @State private var currentPage = 0
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "intro software&apps 1", withExtension: "mp4")!)
    @State var isPlaying: Bool = false

    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue.withAlphaComponent(0.5)
    }
    
    var body: some View {
        NavigationStack{
            TabView() {
                let links = ["intro software&apps 1", "All_Intro", "intro software&apps 1"]
                
                let players = links.map {
                    AVPlayer(
                        url: Bundle.main.url(
                            forResource: $0,
                            withExtension: "mp4")!
                    )
                }
                
                SwipeView(videoId: "bWkYonAEgPI", name: "What is Software?",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""", player: players[0])
                
                SwipeView(videoId: "U0nn_2vsuIY", name: "Examples of Computer Applications",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""", player: players[1])
                SwipeView(videoId: "1Kmu36dYWaU", name: "Operating Systems",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""", player: players[2])
                
            }
            .background(.black, ignoresSafeAreaEdges: .top)
            .background(
                Color(red: 240/255, green: 240/255, blue: 240/255),
                ignoresSafeAreaEdges: .bottom
            )
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onAppear {
              setupAppearance()
            }
        }
    }
}

struct SwipeView: View {
    let videoId: String
    let name: String
    let desc: String?
    
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State private var expanded = true
    @State private var rating: Int?

    @State var player: AVPlayer
        
    var body: some View {
        NavigationStack {
            VStack (spacing: 10) {
                VideoPlayer(player: player)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 25, topTrailingRadius: 25
                        )
                    )
                    .background(.black)
                    .clipped()
                    .aspectRatio(16/9, contentMode: .fit)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
                
                Text(name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .top])
                
                if let desc {
                    VStack(spacing: 5) {
                        ZStack (alignment: .bottomTrailing){
                            Text(desc)
                                .lineSpacing(7)
                                .padding(.horizontal)
                                .lineLimit(expanded ? nil : 3)
                                .padding(.bottom, 10)
                                .padding(.trailing)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    expanded.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.black)
                                    .rotationEffect(.degrees(expanded ? 180 : 0))
                                    .padding(10)
                                    .background(Circle().fill(.gray.opacity(0.12)))
                            }
                        }
                        .padding(.trailing)
                        
                        if expanded {
                            HStack(spacing: 5) {
                                ForEach(0..<5) { i in
                                    Button(action: {
                                        withAnimation {
                                            rating = rating == i ? nil : i
                                        }
                                    }) {
                                        Image(systemName: rating ?? -1 >= i ? "star.fill" : "star")
                                    }
                                }
                            }
                            .foregroundStyle(.blue.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                NavigationLink(destination: PracticeView()) {
                    Text("Practice Problems")
                        .font(.system(size: 19))
                        .padding(15)
                        .padding(.horizontal, 15*2)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .background(RoundedRectangle(cornerRadius: 30).fill(.blue))
                    
                }
                .padding(.bottom, 65)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
        }
    }
}

#Preview {
    VideoView()
}
