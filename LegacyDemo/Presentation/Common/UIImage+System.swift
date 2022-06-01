//
// UIImage (System)
// LegacyDemo
//
// Created by Eugene Egorov on 11 April 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

extension UIImage {
    static func system(name: String) -> UIImage? {
        UIImage(systemName: name)
    }
}
