//
//  UIView.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
