////
////  HomeView.swift
////  EnvisionTech
////
////  Created by Justin Hudacsko on 12/4/23.
////
//
import SwiftUI
//
enum Theme: String {
    case Maroon
    case Dark
    case Light
}

enum AssetsColor : String {
    case background
    case button
    case buttonText
    case plainText
    case symbol
}

struct TabBarView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State var selectedTab = "Home"
    @Binding var pages: [TabBarPage]
    init(pages: Binding<[TabBarPage]>) {
        UITabBar.appearance().isHidden = true
        self._pages = pages
    }
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedTab) {
                    ForEach(pages) { item in
                        item.page
                            .tag(item.tag)
                    }
                }
                
                HStack {
                    ForEach(Array(pages.enumerated()), id: \.offset) { offset, item in
                        if offset > 0 {
                            RoundedRectangle(cornerRadius: 5.0)
                                .frame(width: 2, height: 25)
                                .foregroundStyle(Color("\(currtheme)-buttonText"))
                        }
                        Button(action: { self.selectedTab = item.tag }) {
                            ZStack {
                                Image(systemName: item.icon)
                                    .foregroundColor(self.selectedTab == item.tag ? Color("\(currtheme)-symbol") : Color("\(currtheme)-buttonText"))
                                    .imageScale(.large)
                                    .padding(7)
                                    .fontWeight(item.icon.contains("fill") ? .regular : .bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(5)
                .background(Color("\(currtheme)-button"))
                .cornerRadius(25)
                .padding()
            }
        }
    }
}

struct Home: View {
    @AppStorage("theme") var currtheme: String = "Light"
    @State var courses: [CourseBody] = []
    
    var body: some View {
        VStack {
            Text("Featured Courses")
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .fontDesign(.rounded)
                .font(.title)
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            NavigationStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(courses, id: \.name) { course in
                            VStack {
                                NavigationLink(destination: UnitView()) {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(Color("\(currtheme)-button"))
                                        .frame(width: 85, height: 85)
                                        .overlay(
                                            Image(systemName: course.icon)
                                                .font(.title)
                                                .foregroundStyle(Color("\(currtheme)-symbol"))
                                        )
                                        .shadow(color: Color("\(currtheme)-shadow"), radius: 2.0, x: 2, y: 2)
                                }
                                Text(course.name)
                                    .foregroundStyle(Color("\(currtheme)-plainText"))
                                    .fontDesign(.rounded)
                                    .font(.headline)
                                    .padding(.vertical, 10)
                            }
                            .padding(5)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Text("Jump Back In")
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .fontDesign(.rounded)
                .font(.title)
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let units = [
                UnitBody(name: "Software Fundamentals", icon: "puzzlepiece.fill"),
                UnitBody(name: "Web Tools", icon: "bubble.right.fill"),
            ]
            ForEach(Array(units.enumerated()), id: \.offset) { offset, unit in
                TopView(unit: unit, index: offset)
                    .clipShape(.rect(bottomLeadingRadius: 10, bottomTrailingRadius: 10))
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .shadow(color: Color("\(currtheme)-shadow"), radius: 2.0, x: 2, y: 2)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("\(currtheme)-background"))
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

struct SheetView: View {
    @Binding var currentSelection: CoFounderBody?
    @State var member: CoFounderBody

    @AppStorage("theme") var currtheme: String = "Light"
    @State private var opacity: CGFloat = 0
    
    struct CircularImage: View {
        var systemName: String
        var activity: String
        @AppStorage("theme") var currtheme: String = "Light"
        
        var body: some View {
            VStack{
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color("\(currtheme)-symbol"))
                    .padding(30)
                    .background(
                        Circle()
                            .fill(Color("\(currtheme)-button"))
                    )
                Text(activity)
                    .foregroundStyle(Color("\(currtheme)-plainText"))
                    .bold()
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(member.name)
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 250)
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
                            .foregroundStyle(Color("\(currtheme)-symbol"))
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
            
            HStack {
                Divider()
                    .frame(width: 50, height: 7)
                    .overlay(Rectangle().fill(Color("\(currtheme)-button")))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(Array(member.likes.enumerated()), id: \.offset) { index, like in
                    if index > 0 {
                        Spacer()
                    }
                    CircularImage(systemName: like.icon, activity: like.name)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 25)
            .padding(.vertical, 5)
            
            Text("    "+member.description)
                .padding()
                .minimumScaleFactor(0.3)
            
            VStack(alignment: .leading, spacing: 7) {
                ForEach(member.info, id: \.text) { info in
                    InfoLabel(systemName: info.icon, text: info.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .foregroundStyle(Color("\(currtheme)-plainText"))
        .background(Color("\(currtheme)-background"))
    }
    
    struct InfoLabel: View {
        @AppStorage("theme") var currtheme: String = "Light"
        var systemName: String
        var text: String

        var body: some View {
            Label {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.accentColor)
            } icon: {
                Image(systemName: systemName)
                    .foregroundColor(Color("\(currtheme)-button"))
                    .imageScale(.large)
            }
            .padding(.horizontal, 5)
        }
    }
}

struct About: View {
    @State private var currentSelection: CoFounderBody? = nil
    @AppStorage("theme") var currtheme: String = "Light"
    
    @State private var cofounders: [CoFounderBody] = []


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("About Us")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                    Text("    At EnvisionTech, our mission is to foster digital literacy among our community and educate those underrepresented in the tech industry through free virtual classes.")
                    
                    Text("Meet Our Team")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                    
                    let iterations = Int(ceil(Double(cofounders.count) / 2))
                    Grid {
                        ForEach(0..<iterations, id: \.self) { row in
                            let columns = (row+1)*2 > cofounders.count ? 1 : 2
                            GridRow {
                                ForEach(0..<columns, id: \.self) { col in
                                    let index = row*2+col
                                    let cofounder = cofounders[index]
                                    
                                    Button {
                                        currentSelection = cofounder
                                    } label: {
                                        VStack {
                                            Image(cofounder.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .mask(Circle())
                                                .shadow(color: Color("\(currtheme)-shadow").opacity(5.0), radius: 5.0)
                                            
                                            Text(cofounder.name)
                                                .font(.subheadline)
                                                .bold()
                                        }
                                        .frame(width: 160, height: 160)
                                        .padding(5)
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
                            .gridCellColumns(columns == 1 ? 2 : 1)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .task({
            if cofounders.isEmpty {
                fetchAbout()
            }
        })
        .foregroundStyle(Color("\(currtheme)-plainText"))
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .background(Color("\(currtheme)-background"))
    }
    
    func fetchAbout() {
        guard let url = URL(string: "http://192.168.0.134:5000/about") else {
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

struct Search: View {
    @State var searchText: String = ""

    var body: some View {
        VStack {
            SearchableCustom(searchtxt: $searchText)
                .padding(.horizontal)
        }
    }
}

struct HomeView: View {
    @State var courses: [CourseBody] = []
    @AppStorage("theme") var currtheme: String = "Light"
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    
    static func storeTheme(theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        UserDefaults.standard.synchronize()
    }
    
    var body: some View {
        NavigationStack {
            Section {
                VStack(spacing: 0) {
                    Spacer()
                    
                    TabBarView(pages: .constant(
                        [
                            TabBarPage(page: AnyView(Home(courses: courses)), icon: "house.fill", tag: "Home"),
                            TabBarPage(page: AnyView(Search()), icon: "magnifyingglass", tag: "Search"),
                            TabBarPage(page: AnyView(BlogView()), icon: "newspaper.fill", tag: "Blog"),
                            TabBarPage(page: AnyView(About()), icon: "questionmark", tag: "FAQ")
                        ]
                        )
                    )
                    
                }
                .task({
                    if courses.isEmpty {
                        fetchCourses()
                    }
                })
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
                .padding(.bottom, -8)
            }
        }
    }
    
    func fetchCourses(){
        guard let url = URL(string: "http://192.168.0.134:5000/courses") else {
            print("no")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("no 2")
                return
            }
            
            guard let data = data else {
                print("no 3")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode([CourseBody].self, from: data) else { 
                print("no u")
                return
            }
            
            decodedData.forEach { unit in
                courses.append(unit)
            }
            
        }.resume()
    }
}

struct CourseBody: Decodable {
    var name: String
    var icon: String
}

struct SearchableCustom: View {
    @AppStorage("theme") var currtheme: String = "Light"
    @Binding var searchtxt: String
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchtxt)
                .focused($isSearchFocused)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            
            if isSearchFocused && !searchtxt.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .onTapGesture {
                        searchtxt = ""
                    }
                    .foregroundStyle(.gray)
            }
        }
        .foregroundStyle(Color("\(currtheme)-buttonText"))
        .padding(.horizontal)
        .background(Color("\(currtheme)-background"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("\(currtheme)-symbol"), lineWidth: 1)
        )
    }
}


#Preview {
    HomeView()
}
    

extension Color {
    static func appColor(_ name: AssetsColor, theme: Binding<String>, mode: String? = nil) -> Color {
        if let mode {
            return Color("\(mode)-\(name.rawValue)")
        }
        
        print(theme.wrappedValue)
        return Color("\(theme)-\(name.rawValue)")
    }
}


struct TabBarPage: Identifiable {
    var id = UUID()
    var page: AnyView
    var icon: String
    var tag: String
}
