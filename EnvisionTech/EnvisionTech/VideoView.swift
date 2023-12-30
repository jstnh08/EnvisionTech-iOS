import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoId: String
    func makeUIView(context: Context) ->  WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let demoURL = URL(string: "https://www.youtube.com/embed/\(videoId)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: demoURL))
    }
}

struct VideoView: View {
    @State private var currentPage = 0
    @AppStorage("theme") var currtheme: String = "Light"

    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = .red.withAlphaComponent(0.3)
    }
    
    var body: some View {
        NavigationStack{
            TabView() {
                SwipeView(videoId: "bWkYonAEgPI", name: "What is Software?",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""")
                
                SwipeView(videoId: "U0nn_2vsuIY", name: "Examples of Computer Applications",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""")
                SwipeView(videoId: "1Kmu36dYWaU", name: "Operating Systems",
                          desc: """
Discover the heartbeat of technology in this sneak peek into software! Uncover the code driving our devices and beloved apps like Snapchat and Zoom.

See how software crafts our tech experiences, from gaming to messaging. Join us for a glimpse into the enchanting world making our digital gadgets thrive!
""")
                
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onAppear {
              setupAppearance()
            }
            .background(Color("\(currtheme)-background"))
        }
    }
}

struct SwipeView: View {
    let videoId: String
    let name: String
    let desc: String?
    
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State private var descExpanded = false
    @State private var descDegrees = 0.0
    @State private var limit = 3
    
    @State private var unitExpanded = true
    @State private var unitDegrees = 90.0
    
    @State private var showingComments = false
    
    func getLineLimit() -> Int? {
        return descExpanded ? nil : 3
    }
    
    func actionImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title3)
    }
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 10) {
                YouTubeView(videoId: videoId)
                    .frame(width: .infinity, height: 215)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
                HStack {
                    Group {
                        HStack {
                            actionImage(systemName: "hand.thumbsup")
                            Text("127")
                                .bold()
                            Divider()
                                .frame(width: 1, height: 25)
                                .overlay(RoundedRectangle(cornerRadius: 5))
                            actionImage(systemName: "hand.thumbsdown")
                        }
                        
                        Button(action: {showingComments.toggle()}) {
                            HStack {
                                actionImage(systemName: "bubble.left")
                                Text("29")
                                    .bold()
                            }
                        }
                        .sheet(isPresented: $showingComments) {
                            CommentView()
                                .presentationDetents([.fraction(0.8), .large])
                        }
                        
                        actionImage(systemName: "arrowshape.turn.up.forward")
                        actionImage(systemName: "bookmark")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 25.0).fill(Color("\(currtheme)-button")))
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Rectangle())
                    .padding(.vertical)
                
                Text(name)
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                
                if let desc {
                    ZStack (alignment: .bottomTrailing){
                        Text(desc)
                            .padding(.horizontal)
                            .lineLimit(getLineLimit())
                        
                        Image(systemName: "chevron.down")
                            .bold()
                            .onTapGesture {
                                descExpanded.toggle()
                                withAnimation(Animation.easeInOut(duration: 0.5)) {
                                    descDegrees += 180.0
                                }
                                
                            }
                            .rotationEffect(.degrees(descDegrees))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                                
                NavigationLink(destination: PracticeView()) {
                    HStack{
                        Text("Complete Practice Problems")
                            .bold()
                        
                        Image(systemName: "arrowshape.right.fill")
                        
                    }
                    .foregroundStyle(.accent)
                    .padding(.all, 15)
                    .background(Color("\(currtheme)-button"))
                    .cornerRadius(8)
                    
                }
                .padding(.top, 15)
                .padding(.bottom, 65)
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(Color("\(currtheme)-plainText"))
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color("\(currtheme)-background"))
        }
    }
}

#Preview {
    VideoView()
}
