//
//  Sequence.swift
//  ModalKit
//
//  Created by Emre Armagan on 29.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
