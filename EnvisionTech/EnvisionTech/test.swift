import SwiftUI

struct SaveDetails: Identifiable {
    let name: String
    let error: String
    let id = UUID()
}

struct Credentials {
    var userId: Int
    var accessToken: String
}

class WebScraperService {
    static let shared = WebScraperService()
    
    private init () {}
    
    func fetchComments(route: String, accessToken: String?) async throws -> [CommentResponse] {
        let url = try URL.apiRoute(route: route)
        
        let request = createRequest(url: url, method: "GET", accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try processResponse(data: data, response: response, method: "GET")
    }
    
    func createRequest(url: URL, method: String, accessToken: String?, postData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method
        
        if method == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData
        }
        return request
    }
    
    func processResponse(data: Data, response: URLResponse, method: String) throws -> [CommentResponse] {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder.commentDecoder
        
        guard response.statusCode == 200 else {
            guard let decodedError = try? decoder.decode(ErrorResponse.self, from: data) else {
                throw APIError.invalidResponse
            }
            throw APIError.serverError(message: decodedError.error)
        }
        
        guard let decodedComments = try? decoder.decode([CommentResponse].self, from: data) else {
            throw APIError.invalidData
        }
        
        return decodedComments
    }
}

class CommentViewModel: ObservableObject {
    @Published var text = ""
    var replyingTo: Int?
    
    var accessToken: String?
    var userId: Int?
    
    @Published var postedReplies: [CommentResponse] = []

    init() {
        if let credentials = getJWT() {
            accessToken = credentials.accessToken
            userId = credentials.userId
        }
    }
    
    func getJWT() -> Credentials? {
        let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                          kSecAttrService as String: "com.myapp.envisiontech",
                                          kSecMatchLimit as String: kSecMatchLimitOne,
                                          kSecReturnAttributes as String: true,
                                          kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let searchStatus = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard searchStatus == errSecSuccess else {
            return nil
        }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let accessToken = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            return nil
        }
        
        if let userId = Int(account) {
            return Credentials(userId: userId, accessToken: accessToken)
        }
        return nil
    }
}

class CommentRowViewModel: ObservableObject {
    var comment: CommentResponse
    @ObservedObject var commentViewModel: CommentViewModel

    @Published var likedComment: Bool
    @Published var likeCount: Int
    
    @Published var replyCount: Int
    @Published var repliesExpanded: Bool = false
    @Published var replies: [CommentResponse]?
    @Published var showRepliesUntil: Int = 0
    
    var isReply: Bool

    init(comment: CommentResponse, likedComment: Bool, commentViewModel: CommentViewModel, isReply: Bool) {
        self.comment = comment
        self.commentViewModel = commentViewModel
        self.likedComment = likedComment
        self.likeCount = comment.countLikes
        self.replyCount = comment.countReplies
        self.isReply = isReply
    }
    
    func likeTask() {
        Task {
            likedComment.toggle()
            likeCount += likedComment ? 1 : -1
            await handleErrors(task: { try await postLike() })
        }
    }
    
    func replyTask() {
        Task {
            if replies == nil {
                replies = await handleErrors(task: { try await fetchReplies() })
            }
            if let replies {
                showRepliesUntil = min(replies.count, showRepliesUntil+3)
                replyCount = replies.count - showRepliesUntil
                repliesExpanded = true
            }
        }
    }
    
    func handleErrors<T>(task: () async throws -> T) async -> T? {
        do {
            let result = try await task()
            return result
        } catch let error as APIError {
            switch error {
            case .invalidURL:
                print("nivalid urlll")
            case .invalidParameters:
                print("parameters invalid")
            case .invalidResponse:
                print("response ..")
            case .serverError(let message):
                print("uhh \(message)")
            case .invalidData:
                print("invalid data")
            }
        } catch {
            print("unexpected error \(error)")
        }
        return nil
    }
    
    func postLike() async throws {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        let url = try URL.apiRoute(route: "like/\(comment.id)")
        let request = createPostRequest(url: url, accessToken: accessToken)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    func createPostRequest(url: URL, accessToken: String, postData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        return request
    }
    
    func fetchReplies() async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        let url = try URL.apiRoute(route: "replies/\(comment.id)")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder.commentDecoder
        
        guard response.statusCode == 200 else {
            guard let decodedError = try? decoder.decode(ErrorResponse.self, from: data) else {
                throw APIError.invalidResponse
            }
            throw APIError.serverError(message: decodedError.error)
        }
        
        guard let decodedComments = try? decoder.decode([CommentResponse].self, from: data) else {
            throw APIError.invalidData
        }
        
        return decodedComments
    }
}

struct CommentRowView: View {
    let dateFormatter = RelativeDateTimeFormatter()
    @StateObject private var commentModel: CommentRowViewModel
    
    init(comment: CommentResponse, commentViewModel: CommentViewModel, isReply: Bool = false) {
        _commentModel = StateObject(wrappedValue: CommentRowViewModel(comment: comment, likedComment: comment.userLiked, commentViewModel: commentViewModel, isReply: isReply))
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        displayUser()
                        displayText()
                        
                        if !commentModel.isReply {
                            displayReplyButton()
                        }
                    }
                    
                    Spacer()
                    
                    displayHeart()
                }
                
                if !commentModel.isReply {
                    displayPostedReplies()
                }
            }
        }
        .listRowBackground(Color.clear)
    }
    
    func displayPostedReplies() -> some View {
        VStack(alignment: .leading) {
            let replies = commentModel.commentViewModel.postedReplies.filter({ $0.parentId == commentModel.comment.id })
            ForEach(replies, id: \.id) { reply in
                CommentRowView(comment: reply, commentViewModel: commentModel.commentViewModel, isReply: true)
            }
            
            if commentModel.repliesExpanded == true, let replies = commentModel.replies {
                ForEach(0..<commentModel.showRepliesUntil, id: \.self) { i in
                    let reply = replies[i]
                    CommentRowView(comment: reply, commentViewModel: commentModel.commentViewModel, isReply: true)
                }
            }
            
            if commentModel.replyCount > 0 {
                Button(action: { commentModel.replyTask() }) {
                    Text("\(commentModel.replyCount) replies lol")
                }
                .background(.red)
            }
        }
    }
    
    func displayReplyButton() -> some View {
        Button(action: {
            commentModel.commentViewModel.text = "@Anonymous "
            commentModel.commentViewModel.replyingTo = commentModel.comment.id
        }) {
            Text("Reply")
        }
        .background(.blue)
    }
    
    func displayHeart() -> some View {
        VStack(spacing: 5) {
            Image(systemName: commentModel.likedComment ? "heart.fill" : "heart")
                .foregroundStyle(commentModel.likedComment ? .red : .gray)
                .phaseAnimator([false, true], trigger: commentModel.likedComment) { content, phase in
                    content
                        .offset(y: commentModel.likedComment && phase ? -5 : 0)
                        .scaleEffect(commentModel.likedComment && phase ? 1.25 : 1)
                } animation: { phase in
                    phase ? .spring(duration: 0.3) : .default
                }
                .onTapGesture {
                    commentModel.likeTask()
                }
            
            Text("\(commentModel.likeCount)")
        }
        .padding(.leading)
    }
    
    func displayText() -> some View {
        Text(commentModel.comment.text)
            .font(.system(size: 17))
    }
    
    func displayUser() -> some View {
        Text("Anonymous • \(Date().timeIntervalSince(commentModel.comment.postDate) <= 10 ? "now" : dateFormatter.localizedString(for: commentModel.comment.postDate, relativeTo: Date()))")
            .font(.subheadline)
            .bold()
    }
}

struct test: View {
    @State private var postedComments: [CommentResponse] = []
    @State private var comments: [CommentResponse]? = nil
        
    @State var loadingMore: Bool = false
    @State var outOfComments: Bool = false
    
    @State private var initialSnapshot: Int?
    @State private var offset: Int = 0
    private var expectedComments = 10
    
    @StateObject var commentViewModel = CommentViewModel()
    
    var body: some View {
        if let comments {
            VStack (spacing: 50){
                TextField("Type ur comment", text: $commentViewModel.text)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    Task {
                        if let comment = await handleErrors(task: { try await postComment() }), comment.count == 1 {
                            let postedComment = comment[0]
                            
                            if commentViewModel.replyingTo != nil {
                                commentViewModel.replyingTo = nil
                                self.commentViewModel.postedReplies.append(postedComment)
                            } else {
                                self.postedComments.append(postedComment)
                            }
                        }
                    }
                }) {
                    Text("submit")
                }
                
                
                List {
                    Group {
                        ForEach(postedComments.reversed(), id: \.id) { comment in
                            CommentRowView(comment: comment, commentViewModel: commentViewModel)
                        }
                        
                        ForEach(Array(comments.enumerated()), id: \.offset) { i, comment in
                            CommentRowView(comment: comment, commentViewModel: commentViewModel)
                                .onAppear {
                                    if !outOfComments && comment == comments.last {
                                        Task {
                                            loadingMore = true
                                            let loadedComments = await handleErrors(task: { try await fetchComments(offset: offset) })
                                            if let loadedComments {
                                                offset += expectedComments
                                                self.comments?.append(contentsOf: loadedComments)
                                            }
                                            loadingMore = false
                                        }
                                    }
                                }
                        }
                    }
                    .listRowInsets(.init(top: 20, leading: 10, bottom: 20, trailing: 10))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .overlay {
                if loadingMore {
                    ProgressView()
                }
            }
        } else {
            ProgressView("Loading...")
                .task {
                    self.comments = await handleErrors(task: { try await fetchComments() })
                    initialSnapshot = self.comments?.first?.id
                    offset += expectedComments
                }
        }
    }
    
    func handleErrors(task: () async throws -> [CommentResponse]) async -> [CommentResponse]? {
        do {
            let result = try await task()
            return result
        } catch let error as APIError {
            switch error {
            case .invalidURL:
                print("nivalid urlll")
            case .invalidParameters:
                print("parameters invalid")
            case .invalidResponse:
                print("response ..")
            case .serverError(let message):
                print("uhh \(message)")
            case .invalidData:
                print("invalid data")
            }
        } catch {
            print("unexpected error \(error)")
        }
        return nil
    }
      
    func createRequest(url: URL, method: String, accessToken: String, postData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method
        
        if method == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData
        }
        return request
    }
        
    func postComment() async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        let url = try URL.apiRoute(route: "comment")
        let parameters = CommentParameters(parentId: commentViewModel.replyingTo, text: commentViewModel.text, postDate: Date())
        
        guard let postData = try? JSONEncoder.commentEncoder.encode(parameters) else {
            throw APIError.invalidParameters
        }
        
        let request = createRequest(url: url, method: "POST", accessToken: accessToken, postData: postData)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try processResponse(data: data, response: response, method: "POST")
    }

    func fetchComments(offset: Int = 0) async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        var route = "comment?offset=\(offset)"
        if let initialSnapshot {
            route += "&snapshot=\(initialSnapshot)"
        }
        
        let url = try URL.apiRoute(route: route)
        
        let request = createRequest(url: url, method: "GET", accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try processResponse(data: data, response: response, method: "GET")
    }
    
    func processResponse(data: Data, response: URLResponse, method: String) throws -> [CommentResponse] {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder.commentDecoder
        
        guard response.statusCode == 200 else {
            guard let decodedError = try? decoder.decode(ErrorResponse.self, from: data) else {
                throw APIError.invalidResponse
            }
            throw APIError.serverError(message: decodedError.error)
        }
        
        guard let decodedComments = try? decoder.decode([CommentResponse].self, from: data) else {
            throw APIError.invalidData
        }
        
        if method == "GET" && decodedComments.count < expectedComments {
            outOfComments = true
        }
        return decodedComments
    }
}

extension JSONDecoder {
    static var commentDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static var commentEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension URL {
    static func apiRoute(route: String) throws -> URL {
        guard let url = URL(string: "http://127.0.0.1:5000/\(route)") else {
            throw APIError.invalidURL
        }
        return url
    }
}

struct CommentResponse: Decodable, Equatable {
    let id: Int
    let text: String
    let postDate: Date
    var countLikes: Int
    let userLiked: Bool
    let countReplies: Int
    let parentId: Int?
    
    static func ==(lhs: CommentResponse, rhs: CommentResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ErrorResponse: Decodable {
    let error: String
}

struct CommentParameters: Codable {
    let parentId: Int?
    let text: String
    let postDate: Date
}

struct LikeParameters: Codable {
    let commentId: Int
}

struct LikeResponse: Decodable {
    let userId: Int
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

