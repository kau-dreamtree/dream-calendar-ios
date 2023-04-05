//
//  MainTopRightView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI

protocol MainTopRightViewDelegate {
    func searchButtonDidTouched()
    func writeButtonDidTouched()
}

struct MainTopRightView: View {
    private let delegate: MainTopRightViewDelegate
    
    init(delegate: MainTopRightViewDelegate) {
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                // TODO: search action 지정 필요
                delegate.searchButtonDidTouched()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
            Button {
                delegate.writeButtonDidTouched()
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
        }
    }
}
