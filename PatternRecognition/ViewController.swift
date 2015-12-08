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
    let scribeView = ScribeView()
    let label = UILabel()
    let clearButton = UIButton()
    
    var string = ""
    {
        didSet
        {
            label.text = string
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        scribeView.delegate = self
        
        label.font = UIFont.systemFontOfSize(200)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.numberOfLines = 10
        
        clearButton.setTitle("Clear", forState: UIControlState.Normal)
        clearButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        clearButton.addTarget(self, action: "clear", forControlEvents: UIControlEvents.TouchDown)
        
        view.addSubview(label)
        view.addSubview(scribeView)
        view.addSubview(clearButton)
    }
    
    func clear()
    {
        string = ""
    }
    
    override func viewDidLayoutSubviews()
    {
        label.frame = view.bounds.insetBy(dx: 50, dy: 50)
        scribeView.frame = view.bounds
        
        clearButton.frame = CGRect(x: 5,
            y: topLayoutGuide.length,
            width: clearButton.intrinsicContentSize().width,
            height: clearButton.intrinsicContentSize().height)
    }
 
}

extension ViewController: ScribeViewDelegate
{
    func scribeView(scribeView: ScribeView, didMatchPattern: String)
    {
        if didMatchPattern == "<"
        {
            string.removeAtIndex(string.endIndex.predecessor())
        }
        else
        {
            string += didMatchPattern
        }
    }
}

