//
//  OilGauge.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 1/3/19.
//  Copyright © 2019 Thomas Hurtt. All rights reserved.
//

import Foundation

class OilGauge: GaugeBase  {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    override func initialize() {
        super.initialize()
        self.scaleStartAngle = 90
        self.scaleEndAngle = 270
        self.maxValue = 80
        self.rangeValues = [10, 70, 80]
        self.rangeLabels = ["LOW", "OK", "HIGH"]
        self.rangeColors = [rgb(r:231, g:32, b:43),
                            rgb(r:0, g:255, b:0),
                            rgb(r:231, g:32, b:43)]
        self.style = WMGaugeViewStyle3D()
        self.showRangeLabels = true
        self.scaleDivisions = 5
        self.scaleSubdivisions = 2
        self.unitOfMeasurement = "oil"
        self.unitOfMeasurementFont = UIFont(name:"Helvetica", size:0.08)
        self.rangeLabelsWidth = 0.08
    }
    
    func updateGauge(value:Float) {
        self.value = value
    }
}
