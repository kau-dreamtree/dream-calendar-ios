//
//  HalfSheetController.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/25.
//

import SwiftUI
import CalendarUI

final class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = [.dcMedium, .large()]
            presentation.prefersGrabberVisible = true
            presentation.largestUndimmedDetentIdentifier = .dcMedium
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {

    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) {
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let dcMedium = UISheetPresentationController.Detent.Identifier("dcMedium")
}

extension UISheetPresentationController.Detent {
    static let dcMedium = UISheetPresentationController.Detent.custom(identifier: .dcMedium) { context in
        return CalendarView.bottomViewHeight
    }
}
