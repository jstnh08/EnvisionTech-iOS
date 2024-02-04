import SwiftUI

struct Credentials {
    var userId: Int
    var accessToken: String
}

class CommentViewModel: ObservableObject {
    @Published var text = ""
    @Published var replyingTo: CommentResponse?
    
    @Published var sheet: Bool = true
    
    var accessToken: String?
    var userId: Int?
    
    @Published var alertError: WebError?
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

    init(comment: CommentResponse, commentViewModel: CommentViewModel, isReply: Bool) {
        self.comment = comment
        self.commentViewModel = commentViewModel
        self.likedComment = comment.userLiked
        self.likeCount = comment.countLikes
        self.replyCount = comment.countReplies
        self.isReply = isReply
    }
        
    func likeTask() {
        Task {
            let result = await WebScraperService.shared.handleErrors(task: { try await postLike() })
            switch result {
            case .success():
                likedComment.toggle()
                likeCount += likedComment ? 1 : -1
            case .failure(let error):
                commentViewModel.alertError = error
            }
        }
    }
    
    func replyTask() {
        Task {
            if replies == nil {
                let result = await WebScraperService.shared.handleErrors(task: { try await fetchReplies() })
                switch result {
                case .success(let value):
                    replies = value
                case .failure(let error):
                    commentViewModel.alertError = error
                }
            }
            if let replies {
                showRepliesUntil = min(replies.count, showRepliesUntil+3)
                replyCount = replies.count - showRepliesUntil
                repliesExpanded = true
            }
        }
    }
    
    func postLike() async throws {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        let _: GenericResponse = try await WebScraperService.shared.postComment(route: "like/\(comment.id)", parameters: nil, accessToken: accessToken)
    }
    
    func fetchReplies() async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        return try await WebScraperService.shared.fetchComments(route: "replies/\(comment.id)", accessToken: accessToken)
    }
}

struct CommentRowView: View {
    let dateFormatter = RelativeDateTimeFormatter()
    @StateObject private var commentModel: CommentRowViewModel
        
    init(comment: CommentResponse, commentViewModel: CommentViewModel, isReply: Bool = false) {
        _commentModel = StateObject(wrappedValue: CommentRowViewModel(comment: comment, commentViewModel: commentViewModel, isReply: isReply))
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("Steve Ling")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: commentModel.isReply ? 30 : 40)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        displayUser()
                        displayText()
                        
                        if !commentModel.isReply {
                            displayReplyButton()
                        }
                    }
                    
                    Spacer()
                    
                    displayHeart()
                }
                
                let replies = commentModel.commentViewModel.postedReplies.filter(
                    { $0.parentId == commentModel.comment.id }
                )
                
                if !commentModel.isReply && (commentModel.replyCount > 0 || replies.count > 0 || commentModel.repliesExpanded) {
                    displayPostedReplies(replies: replies)
                }
            }
        }
        .listRowBackground(Color.clear)
    }
    
    func displayPostedReplies(replies: [CommentResponse]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
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
                Button(action: {
                    commentModel.replyTask()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 12, height: 8)
                        Text("Show \(commentModel.replyCount) repl\(commentModel.replyCount > 1 ? "ies" : "y")")
                            .fontWeight(.medium)
                            .font(.subheadline)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundStyle(.gray.opacity(0.8))

            } else if commentModel.repliesExpanded {
                Button(action: {
                    commentModel.repliesExpanded = false
                    commentModel.replyCount = commentModel.replies?.count ?? 0
                    commentModel.replies = nil // for state updates
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .resizable()
                            .frame(width: 15, height: 10)
                        Text("Hide replies")
                            .fontWeight(.medium)
                            .font(.subheadline)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundStyle(.gray.opacity(0.8))
            }
        }
    }
    
    func displayReplyButton() -> some View {
        Button(action: {
            commentModel.commentViewModel.text = "@\(commentModel.comment.user.username) "
            withAnimation {
                commentModel.commentViewModel.replyingTo = commentModel.comment
            }
        }) {
            Text("Reply")
                .foregroundStyle(.gray.opacity(0.8))
                .fontWeight(.medium)
                .font(.subheadline)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func displayHeart() -> some View {
        VStack(spacing: 5) {
            Image(systemName: commentModel.likedComment ? "heart.fill" : "heart")
                .foregroundStyle(commentModel.likedComment ? .blue : .gray)
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
            
            if commentModel.likeCount > 0 {
                Text("\(commentModel.likeCount)")
            }
        }
        .padding(.leading, 10)
    }
    
    func displayText() -> some View {
        Text(commentModel.comment.text)
            .font(.system(size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func displayUser() -> some View {
        Text("\(commentModel.comment.user.username) • \(Date().timeIntervalSince(commentModel.comment.postDate) <= 10 ? "now" : dateFormatter.localizedString(for: commentModel.comment.postDate, relativeTo: Date()))")
            .font(.subheadline)
            .bold()
    }
}

struct CommentView: View {
    @State private var postedComments: [CommentResponse] = []
    @State private var comments: [CommentResponse]? = nil
        
    @State var loadingMore: Bool = false
    @State var outOfComments: Bool = false
    
    @State private var initialSnapshot: Int?
    @State private var offset: Int = 0
    private var expectedComments = 10
    
    @FocusState private var focusedText: Bool

    @StateObject var commentViewModel = CommentViewModel()
        
    var body: some View {
        if let comments {
            VStack(spacing: 0) {
                Section {
                    List {
                        Group {
                            ForEach(postedComments.reversed(), id: \.id) { comment in
                                CommentRowView(comment: comment, commentViewModel: commentViewModel, isReply: false)
                            }
                            
                            ForEach(Array(comments.enumerated()), id: \.offset) { i, comment in
                                CommentRowView(comment: comment, commentViewModel: commentViewModel)
                                    .onAppear {
                                        if !outOfComments && comment == comments.last {
                                            Task {
                                                loadingMore = true
                                                let result = await WebScraperService.shared.handleErrors(task: { try await fetchComments(offset: offset) })
                                                switch result {
                                                case .success(let loadedComments):
                                                    offset += expectedComments
                                                    self.comments?.append(contentsOf: loadedComments)
                                                case .failure(let error):
                                                    commentViewModel.alertError = error
                                                }
                                                loadingMore = false
                                            }
                                        }
                                    }
                            }
                        }
                        .listRowInsets(.init(top: 20, leading: 15, bottom: 20, trailing: 15))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                    .foregroundStyle(.black.opacity(0.9))
                } header: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EnvisionTech Forum")
                            .font(.title)
                            .bold()
                        
                        Text("Create a post or interact with others")
                            .foregroundStyle(.gray.opacity(0.9))
                        
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                    
                } footer: {
                    VStack {
                        ZStack(alignment: .bottom) {
                            VStack {
                                HStack {
                                    Image("Steve Ling")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                                        .frame(width: 30, height: 30)
                                    
                                    if let user = commentViewModel.replyingTo?.user.username {
                                        Text("Replying to \(user)")
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        commentViewModel.text = ""
                                        withAnimation {
                                            commentViewModel.replyingTo = nil
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.caption)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(red:57/255,green:150/255,blue:251/255))
                                .foregroundStyle(.white)
                                .padding(.bottom)
                                .offset(y: commentViewModel.replyingTo != nil ? -85 : 0)
                            }
                            
                            
                            VStack {
                                Divider()
                                    .overlay(
                                        Rectangle()
                                            .fill(.blue)
                                            .frame(height: 1.5)
                                    )
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    Image("Steve Ling")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                    
                                    TextField("", text: $commentViewModel.text, prompt: Text("Add a comment...").foregroundStyle(.black.opacity(0.8)))
                                        .focused($focusedText)
                                        .fontWeight(.medium)
                                        .frame(width: 250, height: 50)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .stroke(.blue.opacity(0.8), lineWidth: 2)
                                                    .frame(height: 50)
                                                
                                                if !commentViewModel.text.isEmpty {
                                                    Button(action: {
                                                        Task {
                                                            let result = await WebScraperService.shared.handleErrors(task: { try await postComments() })
                                                            switch result {
                                                            case .success(let comment):
                                                                if comment.count == 1 {
                                                                    let postedComment = comment[0]
                                                                    
                                                                    if commentViewModel.replyingTo != nil {
                                                                        withAnimation {
                                                                            commentViewModel.replyingTo = nil
                                                                        }
                                                                        self.commentViewModel.postedReplies.append(postedComment)
                                                                    } else {
                                                                        self.postedComments.append(postedComment)
                                                                    }
                                                                    commentViewModel.text = ""
                                                                    focusedText = false
                                                                }
                                                            case .failure(let error):
                                                                commentViewModel.alertError = error
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "arrow.up")
                                                            .bold()
                                                            .foregroundStyle(.blue.opacity(0.8))
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .padding(.trailing)
                                                }
                                            }
                                        )
                                        .onTapGesture {
                                            focusedText = true
                                        }
                                }
                                .padding()
                            }
                            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                        }
                    }
                }
                .onTapGesture {
                    focusedText = false
                }
                .overlay {
                    if loadingMore {
                        ProgressView()
                    }
                }
                .alert(item: $commentViewModel.alertError) { error in
                    Alert(title: Text("Error"), message: Text(error.error), dismissButton: .cancel())
                }
            }
        } else {
            ProgressView("Loading...")
                .task {
                    let result = await WebScraperService.shared.handleErrors(task: { try await fetchComments() })
                    switch result {
                    case .success(let comments):
                        self.comments = comments
                        initialSnapshot = self.comments?.first?.id
                        offset += expectedComments
                    case .failure(let error):
                        commentViewModel.alertError = error
                    }
                }
        }
    }
    
    func postComments() async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }
        
        let parameters = CommentParameters(parentId: commentViewModel.replyingTo?.id, text: commentViewModel.text, postDate: Date())
        
        return try await WebScraperService.shared.postComment(route: "comment", parameters: parameters, accessToken: accessToken)
    }
    
    func fetchComments(offset: Int = 0) async throws -> [CommentResponse] {
        guard let accessToken = commentViewModel.accessToken else {
            throw APIError.serverError(message: "No access token")
        }

        var route = "comment?offset=\(offset)"
        if let initialSnapshot {
            route += "&snapshot=\(initialSnapshot)"
        }
        
        let decodedComments: [CommentResponse] = try await WebScraperService.shared.fetchComments(route: route, accessToken: accessToken)
        
        if decodedComments.count < expectedComments {
            outOfComments = true
        }
        
        return decodedComments
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
    let user: UserResponse
    
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

struct GenericResponse: Decodable {
    let message: String
}

struct UserResponse: Decodable {
    let id: Int
    let username: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidParameters
    case serverError(message: String)
    case invalidData
}

#Preview {
    CommentView()
}


