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
        
        self.setScheduleTimeConstraint()
    }
    
    private func setScheduleTimeConstraint() {
        self.schedule.publisher(for: \.startTime)
            .filter({ [weak self] startTime in
                guard let self = self else { return true }
                return startTime >= self.schedule.endTime
            })
            .map({ date in
                return Calendar.current.date(byAdding: .hour,
                                             value: +1,
                                             to: date) ?? date
            })
            .sink(receiveValue: { [weak self] endTime in
                self?.schedule.endTime = endTime
            })
            .store(in: &self.cancellables)
        
        self.schedule.publisher(for: \.endTime)
            .filter({ [weak self] endTime in
                guard let self = self else { return true }
                return self.schedule.startTime >= endTime
            })
            .map({ date in
                return Calendar.current.date(byAdding: .hour,
                                             value: -1,
                                             to: date) ?? date
            })
            .sink(receiveValue: { [weak self] startTime in
                self?.schedule.startTime = startTime
            })
            .store(in: &self.cancellables)
    }
    
    func removeAllBinding() {
        self.cancellables.removeAll()
    }
}
