//
//  Extensions.swift
//  Car Location
//
//  Created by Andrew Nemtsev on 15/02/2018.
//  Copyright © 2018 Andrew Nemtsev. All rights reserved.
//

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
