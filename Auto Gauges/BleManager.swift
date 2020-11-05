//
//  BleManager.swift
//  Auto Gauges
//
//  Created by Thomas Hurtt on 12/25/18.
//  Copyright © 2018 Thomas Hurtt. All rights reserved.
//

import Foundation

import CoreBluetooth
import BlueCapKit

class BleManager  {
    let manager = CentralManager(options: [CBCentralManagerOptionRestoreIdentifierKey : "hurttlocker.com.Auto-Gauges" as NSString])

    public enum AppError : Error {
        case serviceCharacteristicNotFound
        case serviceDataCharacteristicNotFound
        case serviceNotFound
        case invalidState
        case resetting
        case poweredOff
        case unknown
        case unlikely
    }
    
    let serviceUUID = CBUUID(string: "FFE0")
    let serviceCharacteristic = CBUUID(string: "FFE1")
    var dataCharacteristic: Characteristic
    
    func scanForDevice() {
    
        let stateChangeFuture = manager.whenStateChanges()
        
        // handle state changes and return a scan future if the bluetooth is powered on.
        let scanFuture = stateChangeFuture.flatMap { state -> FutureStream<Peripheral> in
            switch state {
            case .poweredOn:
                DispatchQueue.main.async {
                    print("Start scanning...")
                }
                
                //scan for peripherlas that advertise the ec00 service
                return self.manager.startScanning(forServiceUUIDs: [self.serviceUUID])
            case .poweredOff:
                throw AppError.poweredOff
            case .unauthorized, .unsupported:
                throw AppError.invalidState
            case .resetting:
                throw AppError.resetting
            case .unknown:
                //generally this state is ignored
                throw AppError.unknown
            }
        }
        
        // Connect to the first peripheral that matches the service UUID
        let connectionFuture = scanFuture.flatMap { peripheral -> FutureStream<Void> in
            // stop the scan as soon as we find the first peripheral
            self.manager.stopScanning()
            DispatchQueue.main.async {
                print("Found peripheral \(peripheral.identifier.uuidString). Trying to connect")
            }
            
            // connect to the peripheral in order to trigger the connected mode
            return peripheral.connect(connectionTimeout: 10, capacity: 5) 
        }
        //        let discoveryFuture = connectionFuture.flatMap { [weak peripheral] () -> Future<Void> in
        //            guard let peripheral = peripheral else {
        //                throw AppError.unlikely
        //            }
        //            return peripheral.discoverServices([self.serviceUUID])
        //            }.flatMap { [weak peripheral] () -> Future<Void> in
        //                guard let peripheral = peripheral, let service = peripheral.services(withUUID: self.serviceUUID)?.first else {
        //                    throw AppError.serviceNotFound
        //                }
        //                return service.discoverCharacteristics([self.serviceCharacteristic])
        //        }


        // We will next discover the "ec00" service in order be able to access its characteristics
        let discoveryFuture = connectionFuture.flatMap { peripheral -> Future<Peripheral> in
            return peripheral.discoverServices([self.serviceUUID])
            }.flatMap { discoveredPeripheral -> Future<Service> in
                guard let service = discoveredPeripheral.service(self.serviceUUID) else {
                    throw AppError.serviceNotFound
                }
                peripheral = discoveredPeripheral
                DispatchQueue.main.async {
                    print("Discovered service \(service.uuid.uuidString). Trying to discover characteristics")
                }
                //we have discovered the service, the next step is to discover the "ec0e" characteristic
                return service.discoverCharacteristics([self.serviceCharacteristic])
        } as Future<Peripheral>
        
        /**
         1- checks if the characteristic is correctly discovered
         2- Register for notifications using the dataFuture variable
         */
        let dataFuture = discoveryFuture.flatMap { service -> Future<Characteristic> in
            guard let dataCharacteristic = service.characteristic(self.serviceCharacteristic) else {
                throw AppError.dataCharactertisticNotFound
            }
            self.dataCharacteristic = dataCharacteristic
            DispatchQueue.main.async {
                print("Discovered characteristic \(dataCharacteristic.uuid.uuidString). COOL :)")
            }
            //when we successfully discover the characteristic, we can show the characteritic view
            
            //read the data from the characteristic
            self.read()
            //Ask the characteristic to start notifying for value change
            return dataCharacteristic.startNotifying()
            }.flatMap { characteristic -> FutureStream<(characteristic: Characteristic, data: Data?)> in
                //regeister to recieve a notifcation when the value of the characteristic changes and return a future that handles these notifications
                return characteristic.receiveNotificationUpdates(capacity: 10)
        }
        
        //The onSuccess method is called every time the characteristic value changes
        dataFuture.onSuccess { (_, data) in
            let s = String(data:data!, encoding: .utf8)
            DispatchQueue.main.async {
                print("notified value is \(s)")
            }
        }
        
        func read(){
            //read a value from the characteristic
            let readFuture = self.dataCharacteristic.read(timeout: 5)
            readFuture?.onSuccess { (_) in
                //the value is in the dataValue property
                let s = String(data:(self.dataCharacteristic?.dataValue)!, encoding: .utf8)
                DispatchQueue.main.async {
                    print("Read value is \(s)")
                }
            }
            readFuture?.onFailure { (_) in
                print("read error")
            }
        }
        
//        func write(){
//            self.valueToWriteTextField.resignFirstResponder()
//            guard let text = self.valueToWriteTextField.text else{
//                return;
//            }
//            //write a value to the characteristic
//            let writeFuture = self.dataCharacteristic?.write(data:text.data(using: .utf8)!)
//            writeFuture?.onSuccess(completion: { (_) in
//                print("write succes")
//            })
//            writeFuture?.onFailure(completion: { (e) in
//                print("write failed")
//            })
//        }
        
        
    }
    
    
    
    
//    func scanForDevice() {
//
//        let stateChangeFuture = manager.whenStateChanges()
//
//        let scanFuture = stateChangeFuture.flatMap { [weak manager] state -> FutureStream<Peripheral> in
//            guard let manager = manager else {
//                throw AppError.unlikely
//            }
//            switch state {
//            case .poweredOn:
//                return manager.startScanning(forServiceUUIDs: [self.serviceUUID])
//            case .poweredOff:
//                throw AppError.poweredOff
//            case .unauthorized, .unsupported:
//                throw AppError.invalidState
//            case .resetting:
//                throw AppError.resetting
//            case .unknown:
//                throw AppError.unknown
//            }
//        }
//
//        scanFuture.onFailure { [weak manager] error in
//            guard let appError = error as? AppError else {
//                return
//            }
//            switch appError {
//            case .invalidState:
//                break
//            case .resetting:
//                manager?.reset()
//            case .poweredOff:
//                break
//            case .unknown:
//                break
//            case .unlikely:
//                break
//            case .serviceCharacteristicNotFound:
//                break
//            case .serviceNotFound:
//                break
//            case .serviceDataCharacteristicNotFound:
//                break
//            }
//        }
//
//        var peripheral: Peripheral?
//
//        // The connection future will stop scanning when the device is discovered
//        let connectionFuture = scanFuture.flatMap { [weak manager] discoveredPeripheral  -> FutureStream<Void> in
//            manager?.stopScanning()
//            peripheral = discoveredPeripheral
//            return peripheral!.connect(connectionTimeout: 10.0)
//        }
//
//
//        let discoveryFuture = connectionFuture.flatMap { [weak peripheral] () -> Future<Void> in
//            guard let peripheral = peripheral else {
//                throw AppError.unlikely
//            }
//            return peripheral.discoverServices([self.serviceUUID])
//            }.flatMap { [weak peripheral] () -> Future<Void> in
//                guard let peripheral = peripheral, let service = peripheral.services(withUUID: self.serviceUUID)?.first else {
//                    throw AppError.serviceNotFound
//                }
//                return service.discoverCharacteristics([self.serviceCharacteristic])
//        }
//
//
//
//        var serviceDataCharacteristic: Characteristic?
//
//        let subscriptionFuture = discoveryFuture.flatMap { [weak peripheral] () -> Future<Void> in
//            guard let peripheral = peripheral, let service = peripheral.services(withUUID: self.serviceUUID)?.first else {
//                throw AppError.serviceNotFound
//            }
//            guard let dataCharacteristic = service.characteristics(withUUID: self.serviceCharacteristic)?.first else {
//                throw AppError.serviceCharacteristicNotFound
//            }
//            serviceDataCharacteristic = dataCharacteristic
//            return dataCharacteristic.read(timeout: 10.0)
//            }.flatMap { [weak serviceDataCharacteristic] () -> Future<Void> in
//                guard let serviceDataCharacteristic = serviceDataCharacteristic else {
//                    throw AppError.serviceDataCharacteristicNotFound
//                }
//                return serviceDataCharacteristic.startNotifying()
//            }.flatMap { [weak serviceDataCharacteristic] () -> FutureStream<Data?> in
//                guard let serviceDataCharacteristic = serviceDataCharacteristic else {
//                    throw AppError.serviceDataCharacteristicNotFound
//                }
//                print("DEBUG DESCRIPTION" + serviceDataCharacteristic.debugDescription)
//                return serviceDataCharacteristic.receiveNotificationUpdates(capacity: 10)
//        }
//
//        subscriptionFuture.onSuccess { (data) in
//            let s = String(data:data!, encoding: .utf8)
//            DispatchQueue.main.async {
//                 print("notified value is \(s)")
//            }
//        }
////        dataUpdateFuture.onFailure { [weak peripheral] error in
////            switch error {
////            case PeripheralError.disconnected:
////                peripheral?.reconnect()
////            case AppError.serviceNotFound:
////                break
////            case AppError.serviceCharactertisticNotFound:
////                break
////            default:
////                break
////            }
////        }
//
//
//
//        discoveryFuture.onFailure { [weak peripheral] error in
//            switch error {
//            case PeripheralError.disconnected:
//                peripheral?.reconnect()
//            case AppError.serviceNotFound:
//                break
//            default:
//                break
//            }
//        }
//    }
    
}
