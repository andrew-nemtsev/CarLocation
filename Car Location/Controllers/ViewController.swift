//
//  ViewController.swift
//  Car Location
//
//  Created by Andrew Nemtsev on 15/02/2018.
//  Copyright © 2018 Andrew Nemtsev. All rights reserved.
//

import UIKit
import os.log
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var vehicle: UIImageView!
    @IBOutlet weak var area: GridView!
    var tapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    
    var areaOrigin: CGPoint!
    var prePanAreaOrigin: CGPoint!
    var prePanVehicleLocation: CGPoint!
    
    var vehicleState: Vehicle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleState = Vehicle()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAreaTap))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleAreaPan))
        
        area.addGestureRecognizer(tapRecognizer)
        area.addGestureRecognizer(panRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        areaOrigin = CGPoint( x: area.frame.width / 2.0, y: area.frame.height / 2.0)
        
        vehicle.center = areaOrigin
        area.setOrigin(origin: areaOrigin)
        area.setNeedsDisplay()
    }
    
    @objc func handleAreaTap(tap: UITapGestureRecognizer) {
        if !vehicleState.isMoving {
            moveVehicleToLocation(tap.location(in: self.area))
        }
    }
    
    @objc func handleAreaPan(pan: UIPanGestureRecognizer) {
        if !vehicleState.isMoving {
            switch pan.state {
                case UIGestureRecognizerState.began:
                    prePanAreaOrigin = areaOrigin
                    prePanVehicleLocation = self.vehicle.center
                    break;
                case UIGestureRecognizerState.changed:
                    let translation = pan.translation(in: self.area)
                    if prePanAreaOrigin != nil
                    {
                        self.areaOrigin = prePanAreaOrigin.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
                        self.vehicle.center = prePanVehicleLocation.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
                        
                        self.area.setOrigin(origin: areaOrigin)
                        self.area.setTagret(target: self.vehicle.center)
                        self.area.setNeedsDisplay()
                    }
                    break;
            default:
                break;
            }
        }
    }

    func animateVehicleLocation(_ moveDuration: Double)
    {
        UIView.animate(withDuration: moveDuration,
                                   delay: 0.0,
                                   options: .curveEaseInOut,
                                   animations: {
                                      self.vehicle.center = CGPoint(x: CGFloat(self.vehicleState.x) + self.areaOrigin.x,
                                                                    y: CGFloat(self.vehicleState.y) + self.areaOrigin.y)
                                   },
                                   completion : { finished in
                                      self.vehicleState.isMoving = false
                                   })
    }
    
    func animateVehicleRotation(_ rotationDuration: Double, targetDirection: Double, moveDuration: Double)
    {
        UIView.animate(withDuration: rotationDuration,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                            self.vehicle.transform = CGAffineTransform.init(rotationAngle:CGFloat(targetDirection))
                       },
                       completion : { finished in
                            self.animateVehicleLocation(moveDuration)
                      })
    }
    
    func moveVehicleToLocation(_ point: CGPoint)
    {
        let newPhysCoordX = Double(point.x - areaOrigin.x)
        let newPhysCoordY = Double(point.y - areaOrigin.y)
        
        if (abs(newPhysCoordX) > Double(GridView.CELL_SIZE * GridView.AREA_SIZE)) || (abs(newPhysCoordY) > Double(GridView.CELL_SIZE * GridView.AREA_SIZE))
        {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            return
        }
        
        self.area.setTagret(target: CGPoint(x: CGFloat(newPhysCoordX) + self.areaOrigin.x,
                                            y: CGFloat(newPhysCoordY) + self.areaOrigin.y))
        self.area.setNeedsDisplay()
        
        let targetDirection = caclulateDirection(x1: vehicleState.x, y1: vehicleState.y, x2: newPhysCoordX, y2: newPhysCoordY)
        let rotateDuration = calculateTurnAngle(initial: self.vehicleState.direction, target: targetDirection) / Vehicle.MAX_TURN
        let moveDuration = sqrt(pow((newPhysCoordX - vehicleState.x),2) + pow((newPhysCoordY - vehicleState.y),2)) / Vehicle.MAX_SPEED
        
        os_log("target = %f, current = %f, duration = %f", targetDirection.radiansToDegrees, self.vehicleState.direction.radiansToDegrees, rotateDuration)
        
        self.vehicleState.x = newPhysCoordX
        self.vehicleState.y = newPhysCoordY
        self.vehicleState.direction = targetDirection
        
        vehicleState.isMoving = true
        
        animateVehicleRotation(rotateDuration, targetDirection: targetDirection, moveDuration: moveDuration)
    }
    
    func caclulateDirection(x1: Double, y1: Double, x2: Double, y2: Double) -> Double
    {
        if abs(x2 - x1) < 0.1
        {
            os_log("singularity")
            return y2 > y1 ? -Double.pi / 2 : Double.pi / 2
        }
        else
        {
            var alpha = atan((y2 - y1) / (x2 - x1))
            if (x2 > x1)
            {
                alpha += Double.pi
            }
            os_log("alpha = %f", alpha.radiansToDegrees)
            return alpha
        }
    }
    
    func calculateTurnAngle(initial: Double, target: Double) -> Double {
        let initialCourse = initial < 0 ? 2 * Double.pi + initial : initial
        let targetCourse = target < 0 ? 2 * Double.pi + target : target
        
        var angle = abs(targetCourse - initialCourse).truncatingRemainder(dividingBy: 2 * Double.pi)
        if angle > Double.pi { angle = 2 * Double.pi - angle }
        os_log("angle = %f, initialCourse = %f, targetCourse = %f", angle.radiansToDegrees, initialCourse.radiansToDegrees, targetCourse.radiansToDegrees)
        return angle
    }
}

