//
//  CalendarView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/03.
//

import SwiftUI

enum CalendarUIError: Error {
    case monthIndexError
}

public struct CalendarView: View {
    private let monthInfo: Month?
    
    public init(date: (year: Int, month: Int)? = nil) {
        self.monthInfo = try? Month(date: date)
    }
    
    public var body: some View {
        VStack {
            WeekdayView()
            
            Divider().padding(0)
            
            if let monthInfo = monthInfo {
                VStack {
                    ForEach(0..<5) { weekIndex in
                        if let week = monthInfo[weekIndex] {
                            WeekView(week: week)
                        } else {
                            Text("")
                        }
                        Spacer()
                        Divider()
                    }
                }
            } else {
                Text("error occured")
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.shadowGray, radius: 15, x: 0.2, y: 0.2)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .previewDevice("iPhone 11")
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
    }
}
