//
//  ScheduleDetailView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/30.
//

import SwiftUI

protocol ScheduleDetailViewDelegate {
    func closeDetailView()
    
    func deleteSchedule(_: Schedule)
}

struct ScheduleDetailView: View {
    
    let schedule: Schedule
    let date: Date
    let delegate: ScheduleDetailViewDelegate & AdditionViewPresentDelegate & RefreshMainViewDelegate
    let scheduleManager: ScheduleManager
    
    @State private var isContextMenuOpen: Bool = false
    @State private var isEditingMode: Bool = false
    
    var body: some View {
        NavigationView {
            
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    //TODO: search action 지정 필요
                    delegate.closeDetailView()
                } label: {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigation) {
                HStack {
                    Rectangle()
                        .frame(width: 2, height: 19)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                    Text(self.schedule.title)
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    //TODO: search action 지정 필요
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
                .contextMenu(self.moreContextMenu())
            }
        }
    }
    
    private func moreContextMenu() -> ContextMenu<TupleView<(Button<Text>, Button<Text>)>> {
        ContextMenu(menuItems: {
            Button("수정") {
                self.isEditingMode = true
            }
            Button("삭제") {
                self.delegate.deleteSchedule(self.schedule)
            }
        })
    }
    
    private func scheduleAdditionModalView() -> some View {
        VStack {
            if let scheduleAdditionViewModel = self.scheduleManager.getScheduleAdditionViewModel(withDate: self.date,
                                                                                                 schedule: self.schedule,
                                                                                                 andDelegate: self.delegate) {
            } else {
                Text("")
            }
        }
    }
}

struct ScheduleDetailViewModel {
    let scheduleManager: ScheduleManager
    
    
}
