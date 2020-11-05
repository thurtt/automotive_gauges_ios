//
//  GaugeManager.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 11/2/20.
//  Copyright © 2020 Thomas Hurtt. All rights reserved.
//

import Foundation

class GaugeManager: NSObject {
    var oil:OilGauge?
    var temp:TempGauge?
    var volt:VoltGauge?
    var tach:TachGauge?
    
    var gaugeData:Data = Data()
    
    init (oil:OilGauge, volt:VoltGauge, temp:TempGauge, tach:TachGauge) {
        self.oil = oil
        self.volt = volt
        self.temp = temp
        self.tach = tach
    }
            
    func updateGauges() {
        do {
            let strPacket = String(decoding: gaugeData, as: UTF8.self)
            print("Raw packet string: \(strPacket)")
            let decoder = JSONDecoder()
            let packet = try decoder.decode(GaugePacket.self, from: gaugeData)
            print("packet: oil \(packet.oil) volt: \(packet.voltage) temp: \(packet.dtemp) tach: \(packet.tach)")
            oil!.updateGauge(value: packet.oil)
            volt!.updateGauge(value: packet.voltage)
            temp!.updateGauge(value: packet.dtemp)
            tach!.updateGauge(value: packet.tach)
        } catch {
            print(error.localizedDescription)
        }
        
        gaugeData.removeAll()
    }
    
    @objc func onReceiveBLEData(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let recvData = dict["recvData"] as? Data{
                gaugeData.append(recvData)
                print("last gaugeData Character is \(gaugeData.last!)")
                if gaugeData.last! == 0x0A {
                    updateGauges()
                }
            }
        }
    }
    
    struct GaugePacket : Codable{
        let tach: Int32
        let dtemp: Float
        let oil: Float
        let voltage: Float
    }
}
