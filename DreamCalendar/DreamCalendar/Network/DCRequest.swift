//
//  NetworkContainer.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/02.
//

import Foundation

fileprivate struct NetworkContainer {
    func request(_ request: URLRequest) async throws -> (Int, Data) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (100..<500) ~= httpResponse.statusCode else {
            throw DCError.network(response)
        }
        return (httpResponse.statusCode, data)
    }
}

struct DCRequest {

    static private let ip: String = "http://3.39.195.86"
    static private let networkContainer = NetworkContainer()
    
    func request(with api: APIInfo) async throws -> (Int, Data) {
        let ip = Self.ip
        guard let url = URL(string: ip + api.route) else {
            throw DCError.urlError
        }
        var request = URLRequest(url: url)
        request.httpMethod = api.method.toString()
        api.header?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = try api.body()
        return try await Self.networkContainer.request(request)
    }
}
