//
//  WebScraperService.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/29/23.
//

import Foundation

class WebScraperService {
    static let shared = WebScraperService()
    
    private init () {}
    
    func postComment<T: Decodable>(route: String, parameters: Encodable?, accessToken: String?) async throws -> T {
        let url = try URL.apiRoute(route: route)
        
        var postData: Data?  = nil
        if let parameters {
            guard let encodedParameters = try? JSONEncoder.commentEncoder.encode(parameters) else {
                throw APIError.invalidParameters
            }
            postData = encodedParameters
        }
        
        let request = createRequest(url: url, method: "POST", accessToken: accessToken, postData: postData)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try processResponse(data: data, response: response)
    }
    
    func fetchComments(route: String, accessToken: String?) async throws -> [CommentResponse] {
        let url = try URL.apiRoute(route: route)
        
        let request = createRequest(url: url, method: "GET", accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try processResponse(data: data, response: response)
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
    
    func processResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
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
        
        guard let decodedComments = try? decoder.decode(T.self, from: data) else {
            throw APIError.invalidData
        }
        
        return decodedComments
    }
    
    func handleErrors<T>(task: () async throws -> T) async -> Result<T, WebError> {
        do {
            let result = try await task()
            return .success(result)
        } catch let error as APIError {
            switch error {
            case .invalidURL:
                return .failure(WebError("Invalid URL."))
            case .invalidParameters:
                return .failure(WebError("Invalid Parameers."))
            case .invalidResponse:
                return .failure(WebError("Invalid Response."))
            case .serverError(let message):
                return .failure(WebError(message))
            case .invalidData:
                return .failure(WebError("Invalid Data."))
            }
        } catch {
            return .failure(WebError("An unexpected error occurred"))
        }
    }
}

struct WebError: Error, Identifiable {
    var id: String { error }
    let error: String
    
    init(_ error: String) {
        self.error = error
    }
}
