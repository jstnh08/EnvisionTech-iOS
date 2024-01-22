import SwiftUI
import AVKit

struct test: View {

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 50) {
                ForEach(0..<10) { i in
                    Image("Justin Hudacsko")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 150)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 25)
                        )
                        .scrollTransition(.animated, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.25 : 1.0)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 95)
        .frame(height: 200)
    }
}

#Preview {
    test()
}
