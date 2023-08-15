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
    
    private struct Constraint {
        static let buttonHeight: CGFloat = 20
        static let spacing: CGFloat = 15
        
        static let imageHeightWidth: CGFloat = 20
        
        static let searchImageTitle: String = "magnifyingglass"
        static let writeImageTitle: String = "square.and.pencil"
    }
    
    init(delegate: MainTopRightViewDelegate) {
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: Constraint.spacing) {
            Button {
                // TODO: search action 지정 후 hidden 해지 필요
                delegate.searchButtonDidTouched()
            } label: {
                Image(systemName: Constraint.searchImageTitle)
                    .resizable()
                    .frame(width: Constraint.imageHeightWidth, height: Constraint.buttonHeight)
                    .foregroundColor(.buttonGray)
            }
            .frame(height: Constraint.buttonHeight)
            .hidden()
            Button {
                delegate.writeButtonDidTouched()
            } label: {
                Image(systemName: Constraint.writeImageTitle)
                    .resizable()
                    .frame(width: Constraint.imageHeightWidth, height: Constraint.buttonHeight)
                    .foregroundColor(.buttonGray)
            }
            .frame(height: Constraint.buttonHeight)
        }
    }
}
