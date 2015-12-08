//
//  ViewController.swift
//  PatternRecognition
//
//  Created by Simon Gladman on 07/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    let shapeLayer = CAShapeLayer()
    let cellCount = 8
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        shapeLayer.lineWidth = 2
        
        view.layer.addSublayer(shapeLayer)
    }

    var strokePoints = [CGPoint]()
    
    var minX = CGFloat.max
    var minY = CGFloat.max
    var maxX = CGFloat(0.0)
    var maxY = CGFloat(0.0)
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        strokePoints = [touch.locationInView(self.view)]
        
        minX = CGFloat.max
        minY = CGFloat.max
        maxX = CGFloat(0.0)
        maxY = CGFloat(0.0)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let
            touch = touches.first,
            coalescedTouches = event?.coalescedTouchesForTouch(touch) else
        {
            return
        }
        
        for touch in coalescedTouches
        {
            let locationInView = touch.locationInView(view)
            
            strokePoints.append(locationInView)
            
            minX = min(locationInView.x, minX)
            minY = min(locationInView.y, minY)
            
            maxX = max(locationInView.x, maxX)
            maxY = max(locationInView.y, maxY)
        }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(strokePoints.first!)
        
        for point in strokePoints
        {
            bezierPath.addLineToPoint(point)
        }
        
        
        
        shapeLayer.path = bezierPath.CGPath
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let gestureWidth = abs(minX - maxX)
        let gestureHeight = abs(minY - maxY)
        
        let cellWidth = max(gestureWidth / CGFloat(cellCount - 1), 1)
        let cellHeight = max(gestureHeight / CGFloat(cellCount - 1), 1)
        
        var cells = [[Bool]](count: cellCount, repeatedValue: [Bool](count: cellCount, repeatedValue: false))
        
        let origin = CGPoint(x: min(minX, maxX), y: min(minY, maxY))
        
        for point in strokePoints
        {
            let x = max(Int(round((point.x - origin.x) / cellWidth)), 0)
            let y = max(Int(round((point.y - origin.y) / cellHeight)), 0)
   
            cells[x][y] = true
        }
        
//        for var i = 0 ; i < cellCount ; i++
//        {
//            var foo = ""
//            
//            for var j = 0 ; j < cellCount ; j++
//            {
//                foo += (cells[j][i] ? "◼︎" : "◻︎")
//            }
//            
//            print(foo)
//        }

        let result = cells.flatMap({ return $0 }).reduce(UInt64(0))
        {
            ($0 << 1 | ($1 ? 1 : 0))
        }
        
        //print("patterns[\(result)] = ")
        
        var bestGuess = (UInt64(0), "")
 
        
        for (pattern, letter) in patterns.patterns
        {
            let result = (pattern & result).popcount()
            
            if result > bestGuess.0
            {
               bestGuess = (result, letter)
            }
        }
  
       print("BEST MATCH: ", bestGuess)
        
    }
    
    var patterns = Patterns()

}

extension UInt64
{
    func popcount() -> UInt64
    {
        var copy = self
        var popcount = UInt64(0)
        
        while copy > 0
        {
            popcount += copy & 1
            copy >>= 1
        }
        
        return popcount
    }
}

