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
    
    var string = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        scribeView.delegate = self
        
        label.font = UIFont.systemFontOfSize(72)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        
        view.addSubview(label)
        view.addSubview(scribeView)
    }
    
    override func viewDidLayoutSubviews()
    {
        label.frame = view.bounds
        scribeView.frame = view.bounds
    }
 
}

extension ViewController: ScribeViewDelegate
{
    func scribeView(scribeView: ScribeView, didMatchPattern: String)
    {
        string += didMatchPattern
        
        label.text = string
    }
}

