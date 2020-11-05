//
//  GaugeBase.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 1/3/19.
//  Copyright © 2019 Thomas Hurtt. All rights reserved.
//

import Foundation

class GaugeBase : WMGaugeView  {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    func initialize() {
        self.showUnitOfMeasurement = true
        self.scaleSubdivisionsWidth = 0.002
        self.scaleSubdivisionsLength = 0.04
        self.scaleDivisionsWidth = 0.007
        self.scaleDivisionsLength = 0.07
        self.rangeLabelsFontColor = UIColor.black
        self.rangeLabelsWidth = 0.06
        self.rangeLabelsFont = UIFont(name:"Helvetica", size:0.05)
        
        self.showScale = true
        self.unitOfMeasurementColor = UIColor.white
    }
    
    func rgb(r:Int32, g:Int32, b:Int32) -> UIColor {
        return UIColor(red:CGFloat(r)/255.0, green:CGFloat(g)/255.0, blue:CGFloat(b)/255.0, alpha:1.0)
    }
    
}
