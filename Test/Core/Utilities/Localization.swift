//
//  Localization.swift
//  Test
//
//  Created by Ivan Antonov on 27.11.2025.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}