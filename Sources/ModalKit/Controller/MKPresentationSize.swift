//
//  MKPresentationSize.swift
//  ModalKit
//
//  Created by Emre Armagan on 27.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import Foundation

/// Enum representing different presentation sizes for the view controller.
public indirect enum MKPresentationSize: Hashable {
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

    /// Represents an existing presentation size with an additional height.
    ///
    /// Use this case to add extra height to an existing presentation size.
    /// For example, `.additionalHeight(.medium, 20)` adds 20 points to the medium size.
    ///
    /// - Parameters:
    ///   - base: The base presentation size to which additional height is applied.
    ///   - extraHeight: The additional height to add to the base size in points.
    case additionalHeight(MKPresentationSize, CGFloat)
}
