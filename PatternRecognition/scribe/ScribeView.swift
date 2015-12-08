//
//  ScribeView.swift
//  PatternRecognition
//
//  Created by Simon Gladman on 08/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit


class ScribeView: UIView
{
    let patterns = Patterns().patterns
    let bezierPath = UIBezierPath()
    let shapeLayer = CAShapeLayer()
    let cellCount = 8
    
    weak var delegate: ScribeViewDelegate?
    
    var strokePoints = [CGPoint]()
    
    var minX = CGFloat.max
    var minY = CGFloat.max
    var maxX = CGFloat(0.0)
    var maxY = CGFloat(0.0)
    
    var timer: NSTimer?
    
    var inflight = false
    {
        didSet
        {
            if inflight
            {
                timer?.invalidate()
            }
            
            UIView.animateWithDuration(0.2)
            {
                self.backgroundColor = self.inflight ? UIColor(white: 0.5, alpha: 0.5) : nil
            }
        }
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        shapeLayer.lineWidth = 4

        shapeLayer.shadowColor = UIColor.whiteColor().CGColor
        shapeLayer.shadowOpacity = 1
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        layer.addSublayer(shapeLayer)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        if !inflight
        {
            strokePoints = [touch.locationInView(self)]
            
            minX = CGFloat.max
            minY = CGFloat.max
            maxX = CGFloat(0.0)
            maxY = CGFloat(0.0)
            
            bezierPath.removeAllPoints()
        }
        
        bezierPath.moveToPoint(touch.locationInView(self))
        inflight = true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let
            touch = touches.first,
            coalescedTouches = event?.coalescedTouchesForTouch(touch) else
        {
            return
        }
        
        inflight = true
        
        for touch in coalescedTouches
        {
            let locationInView = touch.locationInView(self)
            
            strokePoints.append(locationInView)
            bezierPath.addLineToPoint(locationInView)
            
            minX = min(locationInView.x, minX)
            minY = min(locationInView.y, minY)
            
            maxX = max(locationInView.x, maxX)
            maxY = max(locationInView.y, maxY)
        }
        
        shapeLayer.path = bezierPath.CGPath
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        timer =  NSTimer.scheduledTimerWithTimeInterval(0.3,
            target: self,
            selector: "timerHandler",
            userInfo: nil,
            repeats: false)
    }
    
    func timerHandler()
    {
        handleGesture()
        
        inflight = false
        
        bezierPath.removeAllPoints()
        shapeLayer.path = bezierPath.CGPath
    }
    
    func handleGesture()
    {
        let gestureWidth = abs(minX - maxX)
        let gestureHeight = abs(minY - maxY)
        
        let cellWidth = max(gestureWidth / CGFloat(cellCount - 1), 1)
        let cellHeight = max(gestureHeight / CGFloat(cellCount - 1), 1)
        
        if (gestureHeight / gestureWidth) < 0.2
        {
            delegate?.scribeView(self, didMatchPattern: " ")
            
            return
        }
        
        var cells = [[Bool]](count: cellCount, repeatedValue: [Bool](count: cellCount, repeatedValue: false))
        
        let origin = CGPoint(x: min(minX, maxX), y: min(minY, maxY))
        
        for point in strokePoints
        {
            let x = max(Int(round((point.x - origin.x) / cellWidth)), 0)
            let y = max(Int(round((point.y - origin.y) / cellHeight)), 0)
            
            cells[x][y] = true
        }
        
        let strokeResult = cells.flatMap({ return $0 }).reduce(UInt64(0))
        {
            ($0 << 1 | ($1 ? 1 : 0))
        }
        
        printToConsole(strokeResult: strokeResult, cells: cells)
        
        
        
        let bestMatch = patterns.reduce((UInt64(0), UInt64(0), ""))
        {
            let popcount = ($1.0 & strokeResult).popcount()
            
            return popcount > $0.0 ? (popcount, $1.0, $1.1) : $0
        }
        
        delegate?.scribeView(self, didMatchPattern: bestMatch.2)
    }
    
    func printToConsole(strokeResult strokeResult: UInt64, cells: [[Bool]])
    {
        print("")
        
        for var i = 0 ; i < cellCount ; i++
        {
            var row = ""
            
            for var j = 0 ; j < cellCount ; j++
            {
                row += (cells[j][i] ? "*" : " ")
            }
            
            print(row)
        }
        
        print("patterns[\(strokeResult)]")
    }
}

// MARK: ScribeViewDelegate protocol

protocol ScribeViewDelegate: class
{
    func scribeView(scribeView: ScribeView, didMatchPattern: String)
}

// MARK: popcount() extension for UInt64

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