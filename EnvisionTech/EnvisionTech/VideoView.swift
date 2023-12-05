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
        }
    }
}

struct SwipeView: View {
    let videoId: String
    let name: String
    let desc: String?
    
    @State private var descExpanded = false
    @State private var descDegrees = 0.0
    @State private var limit = 3
    
    @State private var unitExpanded = true
    @State private var unitDegrees = 90.0
    
    func getLineLimit() -> Int? {
        return descExpanded ? nil : 3
    }

    var body: some View {
        NavigationStack {
            VStack (spacing: 10) {
                HStack (spacing: 30){
                    Label("Software and Applications", systemImage: "network")
                        .bold()
                        .font(.title3)
                    
                    Image(systemName: "magnifyingglass")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.black)
                
                YouTubeView(videoId: videoId)
                    .frame(width: .infinity, height: 215)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding()
                
                Text(name)
                    .font(.title)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                
                if let desc {
                    ZStack (alignment: .bottomTrailing){
                        Text(desc)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                }
                
                Spacer()
                
                NavigationLink(destination: SomeView()) {
                    HStack{
                        Text("Complete Practice Problems")
                            .bold()
                        
                        Image(systemName: "arrowshape.right.fill")
                        
                    }
                    .foregroundStyle(.yellow)
                    .padding(.all, 15)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                }
                .padding(.top, 15)
                .padding(.bottom, 65)
                .frame(maxWidth: .infinity)
                .background(.black)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}

struct SomeView: View {
    var body: some View {
        Text("Detailed View Here!")
    }
}

#Preview {
    VideoView()
}
