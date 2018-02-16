//
//  AreaGridView.swift
//  Car Location
//
//  Created by Andrew Nemtsev on 15/02/2018.
//  Copyright © 2018 Andrew Nemtsev. All rights reserved.
//

import UIKit
import Foundation

class GridView: UIView
{
    static let ORIGIN_SIZE : CGFloat = 10.0
    static let TARGET_SIZE : CGFloat = 20.0
    static let AREA_SIZE : Int = 10
    static let CELL_SIZE : Int = 40
    
    public func setOrigin(origin : CGPoint)
    {
        self.origin = origin
    }
    
    public func setTagret(target : CGPoint)
    {
        self.target = target
    }
    
    private var origin : CGPoint = CGPoint(x: 0, y: 0)
    private var originSize : CGSize = CGSize( width: ORIGIN_SIZE, height: ORIGIN_SIZE)
    private var target : CGPoint = CGPoint(x: 0, y: 0)
    private var targetSize : CGSize = CGSize( width: TARGET_SIZE, height: TARGET_SIZE)
    private var path = UIBezierPath()
    private var originPath = UIBezierPath()
    private var targetPath = UIBezierPath()
    
    override func draw(_ rect: CGRect)
    {
        path = UIBezierPath()
        path.lineWidth = 1.0
        
        let radius = CGFloat(GridView.CELL_SIZE * GridView.AREA_SIZE)
        let minX = -radius + origin.x
        let maxX = radius + origin.x
        let minY = -radius + origin.y
        let maxY = radius + origin.y
        
        for index in -GridView.AREA_SIZE...GridView.AREA_SIZE
        {
            let y = CGFloat(index * GridView.CELL_SIZE) + origin.y
            
            let start = CGPoint(x: max(0, minX), y: y)
            let end = CGPoint(x: min(bounds.width, maxX), y: y)
            
            if rect.contains(start) || rect.contains(end)
            {
                path.move(to: start)
                path.addLine(to: end)
            }
        }
        
        for index in -GridView.AREA_SIZE...GridView.AREA_SIZE
        {
            let x = CGFloat(index * GridView.CELL_SIZE) + origin.x
            
            let start = CGPoint(x: x, y: max(0, minY))
            let end = CGPoint(x: x, y: min(bounds.height, maxY))
            
            if rect.contains(start) || rect.contains(end)
            {
                path.move(to: start)
                path.addLine(to: end)
            }
        }
        
        //Close the path.
        path.close()
        
        UIColor.gray.setStroke()
        path.stroke()
        
        let originRect = CGRect( origin: origin.applying(CGAffineTransform(translationX: -GridView.ORIGIN_SIZE / 2.0, y: -GridView.ORIGIN_SIZE / 2.0)), size: originSize )
        
        if originRect.intersects(rect)
        {
            UIColor.red.setFill()
            originPath = UIBezierPath.init(ovalIn: originRect)
            originPath.fill()
        }
        
        let targetRect = CGRect( origin: target.applying(CGAffineTransform(translationX: -GridView.TARGET_SIZE / 2.0, y: -GridView.TARGET_SIZE / 2.0)), size: targetSize )
        
        if targetRect.intersects(rect)
        {
            UIColor.orange.setFill()
            targetPath = UIBezierPath.init(ovalIn: targetRect)
            targetPath.fill()
        }
    }
}
