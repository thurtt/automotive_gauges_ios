//
//  TempGauge.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 1/3/19.
//  Copyright © 2019 Thomas Hurtt. All rights reserved.
//

import Foundation

class TempGauge: GaugeBase  {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    override func initialize() {
        super.initialize()
        self.scaleStartAngle = 60
        self.scaleEndAngle = 270
        self.maxValue = 240
        self.rangeValues = [120, 220, 240]
        self.rangeLabels = ["COLD", "OK", "HOT"]
        self.rangeColors = [rgb(r:0, g:183, b:255),
                            rgb(r:0, g:255, b:0),
                            rgb(r:231, g:32, b:43)]
        self.style = WMGaugeViewStyle3D()
        self.showRangeLabels = true
        self.scaleDivisions = 4
        self.scaleSubdivisions = 2
        self.unitOfMeasurement = "temp"
        self.rangeLabelsWidth = 0.08
        self.unitOfMeasurementFont = UIFont(name:"Helvetica", size:0.08)
    }
    
    func updateGauge(value:Float) {
        self.value = value
    }

}
