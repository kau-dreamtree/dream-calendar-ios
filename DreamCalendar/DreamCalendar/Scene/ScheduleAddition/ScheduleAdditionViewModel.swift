//
//  ScheduleAdditionViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//

import Foundation
import Combine
import CoreData

final class ScheduleAdditionViewModel: ObservableObject {
    
    @Published var schedule: Schedule
    let viewContext: NSManagedObjectContext
    private var cancellables: Set<AnyCancellable> = []
    
    var defaultStartTime: TimeInfo {
        return self.schedule.startTime.toTimeInfo()
    }
    
    var defaultEndTime: TimeInfo {
        return self.schedule.endTime.toTimeInfo()
    }
    
    init?(_ context: NSManagedObjectContext, title: String = "", isAllDay: Bool = false, date: Date, tag: TagInfo = (type: TagType.babyBlue, title: TagType.babyBlue.defaultTitle)) {
        let startTime = TimeInfo.defaultTime(.start, date: date).toDate()
        let endTime = TimeInfo.defaultTime(.end, date: date).toDate()
        
        self.viewContext = context
        self.schedule = Schedule(context: context)
        
        schedule.id = UUID()
        schedule.title = title
        schedule.isAllDay = isAllDay
        schedule.startTime = startTime
        schedule.endTime = endTime
        schedule.tagId = Int16(tag.type.rawValue)
    }
    
    // TODO: 시작 시간과 종료 시간이 역순이 되지 않도록 조정 필요
    private func checkScheduleTimeConstraint(old oldSchedule: Schedule, new newSchedule: Schedule) {
        guard newSchedule.startTime >= newSchedule.endTime else { return }
        
        if oldSchedule.startTime != newSchedule.startTime {
            self.schedule.endTime = Calendar.current.date(byAdding: .hour,
                                                          value: +1,
                                                          to: newSchedule.startTime) ?? newSchedule.startTime
        } else if oldSchedule.endTime != newSchedule.endTime {
            self.schedule.startTime = Calendar.current.date(byAdding: .hour,
                                                            value: -1,
                                                            to: newSchedule.endTime) ?? newSchedule.endTime
        }
    }
}
