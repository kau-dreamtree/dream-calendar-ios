//
//  DCAdminAPI.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/03/23.
//

import Foundation

#if DEVELOP
extension DCAPI {
    enum Admin: APIInfo {
        case login(email: String, password: String, accessExpiration: Int, refreshExpiration: Int)
        
        var route: String {
            switch self {
            case .login: return "/admin/auth"
            }
        }
        
        var method: HttpMethod {
            switch self {
            case .login: return .post
            }
        }
        
        var header: [(key: String, value: String)]? {
            switch self {
            case .login :
                // TODO: 보안 처리 필요
                return [("Content-Type", "application/json"), ("Authorization", "7KeA7IiY7Iq57JuQ7J6s7Jqw65Oc66a87Yq466as7LWc6rOg")]
            }
        }
        
        
        func body() throws -> Data? {
            let body: [String: Any]
            switch self {
            case .login(let email, let password, let accessExpiration, let refreshExpiration) :
                body = ["email": email, "password": password, "access_expiration": accessExpiration, "refresh_expiration": refreshExpiration]
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
                return TokenResponse.self
            }
        }
        
        func response(_ data: Data) throws -> Decodable? {
            guard let responseType = self.responseType else { return nil }
            do {
                return try JSONDecoder().decode(responseType, from: data)
            } catch {
                throw DCError.decodingError(data)
            }
        }
    }
}
#endif
