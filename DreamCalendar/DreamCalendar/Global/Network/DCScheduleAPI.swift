//
//  DCScheduleAPI.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/06/10.
//

import Foundation

extension DCAPI {
    
    struct ScheduleResponse: Decodable {
        let id: Int64
        let title: String
        let tag: Int
        let is_all_day: Bool
        let start_at: String?
        let end_at: String?
    }
    
    enum Schedule: APIInfo {
        case add(accessToken: String, title: String, tag: Int, isAllDay: Bool, startDate: Date, endDate: Date)
        case schedule(accessToken: String, serverId: Int)
        case schedules(accessToken: String)
        case modify(accessToken: String, serverId: Int64, title: String, tag: Int, isAllDay: Bool, startDate: Date, endDate: Date)
        case delete(accessToken: String, serverId: Int64, title: String, tag: Int, isAllDay: Bool, startDate: Date, endDate: Date)
        
        var route: String {
            switch self {
            case .add, .modify, .delete: return "/schedule"
            case .schedule(_, let id): return "/schedule/\(id)"
            case .schedules: return "/schedules"
            }
        }
        
        var method: HttpMethod {
            switch self {
            case .add: return .post
            case .schedule, .schedules: return .get
            case .modify: return .put
            case .delete: return .delete
            }
        }
        
        var header: [(key: String, value: String)]? {
            switch self {
            case .add(let accessToken, _, _, _, _, _), .schedule(let accessToken, _), .schedules(let accessToken), .modify(let accessToken, _, _, _, _, _, _), .delete(let accessToken, _, _, _, _, _, _) :
                return [("Content-Type", "application/json"), ("Authorization", accessToken)]
            }
        }
        
        
        func body() throws -> Data? {
            let body: [String: Any]
            switch self {
            case .add(_, let title, let tag, let isAllDay, let startDate, let endDate) :
                body = ["title": title, "tag": tag, "is_all_day": isAllDay, "start_at": startDate.serverString, "end_at": endDate.serverString]
            case .modify(_, let serverId, let title, let tag, let isAllDay, let startDate, let endDate), .delete(_, let serverId, let title, let tag, let isAllDay, let startDate, let endDate) :
                body = ["id": serverId, "title": title, "tag": tag, "is_all_day": isAllDay, "start_at": startDate.serverString, "end_at": endDate.serverString]
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
            case .add, .schedule, .modify :
                return ScheduleResponse.self
            case .schedules:
                return [ScheduleResponse].self
            case .delete :
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
    }
}

fileprivate extension Date {
    static let serverDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    var serverString: String {
        return Self.serverDateFormatter.string(from: self)
    }
}
