//
//  BottomCardHelper.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import Foundation
import UIKit

enum CardState {
    case expanded
    case collapsed
}

class BottomCardHelper {
    var currentCardState: CardState!
    var bottomCard: UIViewController!
    var cardHeight: CGFloat!
    var visualEffectView: UIVisualEffectView!
    
    init() {}
    
    init(cardState: CardState, bottomCard: UIViewController, cardHeight: CGFloat, visualEffectView: UIVisualEffectView) {
        self.currentCardState = cardState
        self.bottomCard = bottomCard
        self.cardHeight = cardHeight
        self.visualEffectView = visualEffectView
    }
}
