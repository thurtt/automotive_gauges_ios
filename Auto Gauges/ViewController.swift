//
//  ViewController.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 12/24/18.
//  Copyright © 2018 Thomas Hurtt. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didReceiveBLEData = Notification.Name("didReceiveBLEData")
}

class ViewController: UIViewController {
    //MARK: Properties
    @IBAction func scanButtonCtl(_ sender: UIButton) {
    }
    @IBOutlet weak var tach: TachGauge!
    @IBOutlet weak var oil: OilGauge!
    @IBOutlet weak var temp: TempGauge!
    @IBOutlet weak var volt: VoltGauge!

    var ble: BLEConnectionManager!
    var gaugeManager: GaugeManager!
    
    let moduleName = "DSD TECH"
    let serviceUUID = "FFE0"
    let serviceCharacteristic = "FFE1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // GaugeManager processes the data received from the BLE module and updates
        // the currently rendered gauges.
        gaugeManager = GaugeManager(oil: oil, volt: volt, temp: temp, tach: tach)
        
        // Add an observer to receive the data from the BLE module
        NotificationCenter.default.addObserver(gaugeManager!, selector: #selector(gaugeManager.onReceiveBLEData(_:)), name: .didReceiveBLEData, object: nil)
       
        ble = BLEConnectionManager(uuid: serviceUUID, characteristic: serviceCharacteristic, moduleName: moduleName)

    }
}

