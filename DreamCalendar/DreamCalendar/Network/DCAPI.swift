//
//  DCRequest.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/02.
//

import Foundation

protocol APIInfo {
    var route: String { get }
    var method: HttpMethod { get }
    var header: [(key: String, value: String)]? { get }
    func body() throws -> Data?
    
    var responseType: Decodable.Type? { get }
    func response(_ data: Data) throws -> Decodable?
}

enum HttpMethod {
    case post, get, delete
    
    func toString() -> String {
        switch self {
        case .post : return "POST"
        case .get : return "GET"
        case .delete : return "DELETE"
        }
    }
}

struct DCAPI {
    enum Account: APIInfo {
        case signup(email: String, password: String, username: String)
        case login(email: String, password: String)
        case tokenLogin(authorization: String)
        case logout(authorization: String)
        case leave(authorization: String)
        
        var route: String {
            switch self {
            case .signup: return "/user/create"
            case .login: return "/user/auth/login"
            case .tokenLogin : return "/user/auth/login"
            case .logout : return "/user/auth/logout"
            case .leave : return "/user/auth/delete"
            }
        }
        
        var method: HttpMethod {
            switch self {
            case .signup, .login : return .post
            case .tokenLogin, .logout : return .get
            case .leave : return .delete
            }
        }

        var header: [(key: String, value: String)]? {
            switch self {
            case .tokenLogin(let authorization), .logout(let authorization), .leave(let authorization) :
                return [("Authorization", authorization)]
            default :
                return nil
            }
        }
        
        func body() throws -> Data? {
            let body: [String: Any]
            switch self {
            case .signup(let email, let password, let username) :
                body = ["email": email, "password": password, "username": username]
            case .login(let email, let password) :
                body = ["email": email, "password": password]
            default :
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw DCError.requestError(error)
            }
        }
        
        var responseType: Decodable.Type? {
            switch self {
            case .login :
                return LoginResponse.self
            default :
                return nil
            }
        }
        
        func response(_ data: Data) throws -> Decodable? {
            guard let responseType = self.responseType else { return nil }
            do {
                return try JSONDecoder().decode(responseType, from: data)
            } catch {
                throw DCError.decodingError(error)
            }
        }
        
        struct LoginResponse: Decodable {
            var access_token: String
            var refresh_token: String
        }
    }
}
