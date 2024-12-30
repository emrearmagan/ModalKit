//
//  MKPresentationSize.swift
//  ModalKit
//
//  Created by Emre Armagan on 27.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import Foundation

/// Enum representing different presentation sizes for the view controller.
public enum MKPresentationSize: Hashable {
    /// Represents the maximum size for the presented view.
    case large

    /// Size of the 1/2 of the Screen
    case medium

    /// Size of the 1/4  of the Screen
    case small

    /// Represents a fixed content height.
    /// - Parameter CGFloat: The specific height for the modal.
    case contentHeight(CGFloat)

    /// Represents the intrinsic height based on the content's size.
    case intrinsicHeight
}
