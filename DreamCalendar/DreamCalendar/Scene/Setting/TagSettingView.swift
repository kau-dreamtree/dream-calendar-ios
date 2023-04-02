//
//  TagSettingView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/04/02.
//

import SwiftUI

struct TagSettingView: View {
    
    @Binding private var tags: [Tag]
    @Binding private var didError: Bool
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let topPadding: CGFloat = 20
    }
    
    init(tags: Binding<[Tag]>, didError: Binding<Bool>) {
        self._tags = tags
        self._didError = didError
    }
    
    var body: some View {
        List {
            ForEach(self.tags ) { tag in
                TagBlock(tag: tag, type: .edit)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Constraint.zeroPadding,
                                              leading: Constraint.zeroPadding,
                                              bottom: Constraint.zeroPadding,
                                              trailing: Constraint.zeroPadding))
                    .contentShape(Rectangle())
            }
            .onMove(perform: self.move)
        }
        .listStyle(PlainListStyle())
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
        .onDisappear {
            self.tags.enumerated().forEach { index, tag in
                tag.order = Int16(index + 1)
            }
            do {
                try TagManager.global.saveTagChange()
            } catch {
                self.didError = true
            }
        }
        Spacer()
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        self.tags.move(fromOffsets: source, toOffset: destination)
    }
}
