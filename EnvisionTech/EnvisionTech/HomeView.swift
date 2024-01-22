////
////  HomeView.swift
////  EnvisionTech
////
////  Created by Justin Hudacsko on 12/4/23.
////
//
import SwiftUI

struct Tab: Identifiable {
    var id = UUID()
    var page: AnyView
    var icon: String
    var name: String
}


var allTabs = [
    Tab(page: AnyView(HomePageView()), icon: "house", name: "Home"),
    Tab(page: AnyView(BlogView()), icon: "message", name: "Forum"),
    Tab(page: AnyView(CourseListView()), icon: "book", name: "Courses"),
//    Tab(page: AnyView(SettingsView()), icon: "person.crop.circle", name: "Profile"),
]

struct HomeView: View {
    @State private var activeTab = "Home"
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $activeTab) {
                    ForEach(allTabs) { tab in
                        tab.page
                            .tag(tab.name)
                    }
                }
                customTabBar()
            }
        }
    }
    
    func customTabBar() -> some View {
        HStack {
            ForEach(allTabs) { tab in
                Button(action: {
                    withAnimation {
                        activeTab = tab.name
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: activeTab == tab.name ? "\(tab.icon).fill" : tab.icon)
                            .font(.title2)
                            .scaleEffect(activeTab == tab.name ? 1.2 : 1)

                        Text(tab.name)
                            .font(.footnote)
                            .fontDesign(.rounded)
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundStyle(activeTab == tab.name ? .blue.opacity(0.7) : .gray)
            }
        }
        .padding([.top, .horizontal], 20)
        .padding(.bottom, -15)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    HomeView()
}
