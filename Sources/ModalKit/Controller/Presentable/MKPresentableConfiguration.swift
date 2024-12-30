//
//  MKPresentableConfiguration.swift
//  ModalKit
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import Foundation
import UIKit

/// Configuration object for `MKPresentable` properties.
public struct MKPresentableConfiguration {
    /// A flag indicating whether the presented view controller should have rounded corners.
    public var hasRoundedCorners: Bool

    /// Resistance to dragging. A normalized value between 0 and 1.
    /// `0`: No resistance; the modal moves freely.
    /// `1`: Maximum resistance; the modal cannot move upward.
    public var dragResistance: CGFloat

    /// Determines whether the presented view controller can be dismissed by dragging it downward.
    ///
    /// - If `true`, the presented view can be dragged downward beyond its minimum height to dismiss it.
    /// - If `false`, the presented view cannot be dismissed by dragging, but it can still be resized within its defined bounds.
    public var isDismissable: Bool

    /// A flag indicating whether to show a drag indicator on the presented view.
    public var showDragIndicator: Bool

    /// The size of the drag indicator, if shown.
    public var dragIndicatorSize: CGSize

    /// The color of the drag indicator, if shown.
    public var dragIndicatorColor: UIColor

    /// Scale at which the vc will be automatically dismissed
    public var dismissibleScale: CGFloat

    /// A flag indicating whether the presented view controller should be dismissed when tapping on the dimmed background. Default is `true`.
    public var closeOnTap: Bool

    public init(hasRoundedCorners: Bool = true,
                dragResistance: CGFloat = 0,
                isDismissable: Bool = true,
                showDragIndicator: Bool = true,
                dragIndicatorSize: CGSize = .init(width: 40, height: 5),
                dragIndicatorColor: UIColor = .label,
                dismissibleScale: CGFloat = 0.6,
                closeOnTap: Bool = true
    ) {
        self.hasRoundedCorners = hasRoundedCorners
        self.dragResistance = dragResistance
        self.isDismissable = isDismissable
        self.showDragIndicator = showDragIndicator
        self.dragIndicatorSize = dragIndicatorSize
        self.dragIndicatorColor = dragIndicatorColor
        self.dismissibleScale = dismissibleScale
        self.closeOnTap = closeOnTap
    }
}
