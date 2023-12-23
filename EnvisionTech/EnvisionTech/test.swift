import SwiftUI

struct SaveDetails: Identifiable {
    let name: String
    let error: String
    let id = UUID()
}


struct test: View {
    @State private var didError = false
    @State private var details: SaveDetails?
    let alertTitle: String = "Save failed."
    
    @State var text = ""


    var body: some View {
        VStack() {
            TextField("Type ur comment", text: $text)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                Task {
                    do {
                        try await postComment()
                        print("WORKING!")
                    } catch let error as APIError {
                        switch error {
                        case .invalidURL:
                            print("nivalid urlll")
                        case .invalidParameters:
                            print("parameters invalid")
                        case .invalidResponse:
                            print("response ... bro")
                        case .serverError(let message):
                            print("uhh \(message)")
                        case .invalidData:
                            print("invalid data LMFAOOO")
                        }
                    } catch {
                        print("unexpected error")
                    }
                }
            }) {
                Text("submit")
            }
        }
        .padding()
    }
    
    func postComment() async throws {
        guard let url = URL(string: "http://192.168.0.132:5000/comment") else {
            throw APIError.invalidURL
        }
        
        let parameters = CommentParameters(text: text)
        guard let postData = try? JSONEncoder().encode(parameters) else {
            throw APIError.invalidParameters
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard response.statusCode == 200 else {
            var errorMessage: String = "Error occurred."
            do {
                let decoder = JSONDecoder()
                let decodedError = try decoder.decode(CommentErrorResponse.self, from: data)
                errorMessage = decodedError.error
            } catch {
                throw APIError.invalidData
            }
            throw APIError.serverError(message: errorMessage)
        }
    }
}

struct CommentErrorResponse: Decodable {
    let error: String
}

struct CommentParameters: Codable {
    let text: String
}


enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidParameters
    case serverError(message: String)
    case invalidData
}

#Preview {
    test()
}
