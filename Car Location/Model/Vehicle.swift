//
//  Vehicle.swift
//  Car Location
//
//  Created by Andrew Nemtsev on 15/02/2018.
//  Copyright © 2018 Andrew Nemtsev. All rights reserved.
//

import Foundation

class Vehicle {
    public static let MAX_SPEED : Double = 100
    public static let MAX_TURN : Double = Double.pi
    
    public var direction = 0.0
    public var x = 0.0
    public var y = 0.0
    
    public var isMoving = false
}
