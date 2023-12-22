import SwiftUI


struct test: View {
    // State to control the scale of the 'X'
    @State private var scale: CGFloat = 10.0

    var body: some View {
        Image(systemName: "xmark")
            .bold()
            .scaleEffect(scale)
            .background(
                Image(systemName: "xmark")
                    .scaleEffect(scale+1)
                    .bold()
                    .foregroundStyle(.red)
            )
    }
}


#Preview {
    test()
}
