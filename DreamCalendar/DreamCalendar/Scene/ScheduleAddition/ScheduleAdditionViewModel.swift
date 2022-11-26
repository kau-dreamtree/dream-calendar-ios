//
//  ScheduleAdditionViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/26.
//

import Foundation


enum TimeType {
    case am, pm
    
    var title: String {
        switch self {
        case .am :
            return "오전"
        case .pm :
            return "오후"
        }
    }
}

enum TagType: Int, Codable {
    case babyBlue = 1, green, yellow, orange, red, pink, purple, grey, navy, black
    
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
}

typealias TimeInfo = (date: Date, hour: Int, type: TimeType)
typealias TagInfo = (type: TagType, title: String)

struct ScheduleAdditionViewModel {
    private(set) var title: String = ""
    private var date: Date
    private(set) var startTime: TimeInfo = (date: Date(), hour: 0, type: .am)
    private(set) var endTime: TimeInfo = (date: Date(), hour: 0, type: .am)
    private(set) var tag: TagInfo = (TagType.babyBlue, TagType.babyBlue.defaultTitle)
    
    enum DefaultTimeType {
        case start, end
    }
    
    init(date: Date) {
        self.date = date
        self.startTime = defaultTime(.start)
        self.endTime = defaultTime(.end)
    }
    
    private func loadTagTitle() {
        // TODO: CoreData에서 tag title 가져오기
    }
    
    private func defaultTime(_ type: DefaultTimeType) -> TimeInfo {
        let addValue: Int = type == .start ? 1 : 2
        
        let currentDate = Date()
        var result: TimeInfo
        switch (currentDate.minute > 0, currentDate.hour < 12, currentDate.hour + addValue < 12, currentDate.hour + addValue < 24) {
        case (true, _, true, _) :
            result = (date, currentDate.hour + addValue, .am)
        case (true, _, false, true) :
            result = (date, currentDate.hour + addValue, .pm)
        case (true, _, false, false) :
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
            let time = (currentDate.hour + addValue) % 24
            result = (nextDate, time, .am)
        case (false, true, _, _) :
            result = (date, currentDate.hour, .am)
        case (false, false, _, _) :
            result = (date, currentDate.hour, .pm)
        }
        result.hour = (result.hour % 12 == 0) ? 12 : (result.hour % 12)
        return result
    }
}
