//
//  NetworkContainer.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/02.
//

import Foundation

fileprivate struct NetworkContainer {
    func request(_ request: URLRequest) async throws -> (Int, Data) {
        print("""
        
        Request >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        url : \(request)
        method : \(request.httpMethod ?? "")
        header : \(request.allHTTPHeaderFields ?? [:])
        body : \(String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8) ?? "nil")
        <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        """)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("""
            
            Response >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            statusCode : \((response as? HTTPURLResponse)?.statusCode ?? 0)
            data : \(String(data: data, encoding: String.Encoding.utf8) ?? "nil")
            <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            
            """)
            guard let httpResponse = response as? HTTPURLResponse,
                  (100..<500) ~= httpResponse.statusCode else {
                throw DCError.network(response)
            }
            if httpResponse.statusCode == 408 {
                throw DCError.network(response)
            }
            return (httpResponse.statusCode, data)
        } catch {
            throw DCError.connection
        }
    }
}

struct DCRequest {

    static private let ip: String = {
        #if DEVELOP
        return "https://test.dreamtree.shop"
        #endif
        return "https://api.dreamtree.shop"
    }()
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
