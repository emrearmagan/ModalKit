//
//  UIColor.swift
//  ModalKit
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

extension UIColor {
    /// A computed property that adapts to light and dark mode.
    ///
    /// - Returns: A `UIColor` that adapts based on the current trait environment.
    public static var modalKitBackground: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 26/255, green: 29/255, blue: 33/255, alpha: 1.0)

                default:
                    return .white
            }
        }
    }
}
