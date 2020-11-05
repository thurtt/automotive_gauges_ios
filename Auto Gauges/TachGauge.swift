//
//  TachGauge.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 12/29/18.
//  Copyright © 2018 Thomas Hurtt. All rights reserved.
//

import Foundation

class TachGauge: GaugeBase  {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }

    override func initialize() {
        super.initialize()
        self.scaleStartAngle = 40
        self.scaleEndAngle = 320
        self.maxValue = 6000
        self.rangeValues = [2000, 2500, 3500, 4500, 6000]
        self.rangeLabels = ["OK", "CAM", "", "HIGH", "REDLINE"]
        self.rangeColors = [rgb(r:0, g:255, b:0),
                            rgb(r:0, g:183, b:255),
                            rgb(r:0, g:255, b:0),
                            rgb(r:232, g:231, b:33),
                            rgb(r:231, g:32, b:43)]
        self.style = WMGaugeViewStyle3D()
        self.showRangeLabels = true
        self.scaleDivisions = 5
        self.scaleSubdivisions = 2
        self.unitOfMeasurement = "rpm"
    }
    
    func updateGauge(value:Int32) {
        self.value = Float(value)
    }
}
