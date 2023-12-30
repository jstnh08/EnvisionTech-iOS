import SwiftUI

struct test: View {
    @State private var showingComments = false
    @State private var fraction: CGFloat = 0.78
    
    var body: some View {
        Button("Show Credits") {
            showingComments.toggle()
        }
        .sheet(isPresented: $showingComments) {
            CommentView()
                .presentationDetents([.fraction(fraction)])
        }
    }
}

#Preview {
    test()
}


