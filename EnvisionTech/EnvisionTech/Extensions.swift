//
//  Extensions.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/29/23.
//

import Foundation

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
        guard let url = URL(string: "http://192.168.0.134:5000/\(route)") else {
            throw APIError.invalidURL
        }
        return url
    }
}
