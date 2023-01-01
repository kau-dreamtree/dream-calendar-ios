//
//  TagType.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/22.
//

import Foundation

typealias TagInfo = (type: TagType, title: String)

enum TagType: Int, Codable {
    case babyBlue = 1, green, yellow, orange, red, pink, purple, grey, navy, black
    
    var id: Int16 {
        return Int16(self.rawValue)
    }
    
    var defaultTitle: String {
        switch self {
        case .babyBlue : return "베이비 블루"
        case .green : return "그린"
        case .yellow : return "옐로우"
        case .orange : return "오렌지"
        case .red : return "레드"
        case .pink : return "핑크"
        case .purple : return "퍼플"
        case .grey : return "그레이"
        case .navy : return "네이비"
        case .black : return "블랙"
        }
    }
    
    var defaultOrder: Int16 {
        return self.id
    }
}
