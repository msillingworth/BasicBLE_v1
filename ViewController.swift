//
//  ViewController.swift
//  BasicBLE_v1
//
//  Created by Mark Illingworth on 6/3/17.
//  Copyright © 2017 Mark Illingworth. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // Set up a central and peripheral
    var central: CBCentralManager!
    var peripheral: CBPeripheral!
    
    // Service UUIDs
    let POLARH7_HRM_HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
    let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180A")
    let POLARH7_HRM_DEVICE_BATTERY_SERVICE_UUID = CBUUID(string: "180F")
    
    // Characteristic UUIDs
    let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37") // uInt8 unsigned 8 bit integer
    let POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID = CBUUID(string: "2A38")
    let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29") //UTF8s  UTF-8 String
    let POLARH7_HRM_DEVICE_BATTERY_LEVEL_CHARACTERISTIC_UUID = CBUUID(string: "2A19") // UInt8 [Max 100, Min 0]
    
    // Properties
    var heartRateLabel: UILabel!
    var manufacturer: UILabel!
    
    // APP Launch Screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize central manager on load
        
        central = CBCentralManager(delegate: self, queue: nil)
        
        
    }

    // MARK:- CBCentralManagerDelegate
    
    // centralManagerDidUpdateState is a method called whenever the device state changes
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // check the BLE state
        
        if central.state == .poweredOn {
            NSLog("Bluetooth is powered on and scanning for peripherals")
            central.scanForPeripherals(withServices: nil, options: nil)
        } else if central.state == .poweredOff {
           NSLog("Error handling for .poweredOff state here")
        } else if central.state == .resetting {
            NSLog("Error handling for .poweredOff state here")
        } else if central.state == .unauthorized {
            NSLog("Error handling for .unauthorized state here")
        } else if central.state == .unknown {
            NSLog("Error handling for .unknown state here")
        } else if central.state == .unsupported {
            NSLog("Error handling for .unsupported state here")
        }
    }
    
    // centralManagerDidDiscoverPheripheral is a method that is called with the CBPeripheral class as a main input parameter.  This method contains most of the information there is to know about a BLE peripheral.
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if true {
            // If a perhiperal is found - stop scanning for peripherals
            self.central.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            // Create a connection between the central and the peripheral
            central.connect(peripheral, options: nil)
            NSLog("Making Central-Perhipheral connection now ...")
        }
    }
    
    // centralManagerDidConnectPeripheral is a method that is called when you have successfully connected to the BLE peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    // centralManagerdidDisconnectPeripheral is called when a conection is lost.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // ToDo: update connection lost code
    }
    
    // MARK:- CBPeripheralManagerDelegate
    
    // didDiscoverServices - Invoked when you discover the peripheral's available services
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            NSLog("Discovered service: %@", service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
     // didDiscoverCharacteristicsFor - Invoked when you discover the peripheral's available services
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
                if (service.uuid == POLARH7_HRM_HEART_RATE_SERVICE_UUID) || (service.uuid == POLARH7_HRM_DEVICE_INFO_SERVICE_UUID) {
                    for characteristic in service.characteristics! {
                        if characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID || characteristic.uuid == POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID || characteristic.uuid == POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID {
                            self.peripheral.setNotifyValue(true, for: characteristic)
                            NSLog("Line 109")
                        }
                    }
                }
    }
    
    // didUpdateValueForCharacteristics - 
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var heartRateData: Data!
        var manufacturerName: Data!
        var bodyLocation: Data!
        
        if characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID {
            heartRateData = characteristic.value!
            print("Your heart rate is %@", heartRateData)
            
            if let str = String(data: heartRateData, encoding: String.Encoding.utf8) {
                heartRateLabel.text = String(str)
            } else {
                print("not a valid UTF-8 sequence")
            }
            
            // heartRateLabel?.text = heartRateData
        } else if characteristic.uuid == POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID {
            manufacturerName = characteristic.value!
            print("Manufacturere name is %@", manufacturerName)
        } else if characteristic.uuid == POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID {
            bodyLocation = characteristic.value!
            print("Body Location is: %@", bodyLocation)
        }
    }
    
    
} // This is the end of the class ViewController


// MARK: -  CBCharacteristic Helper Methods

    // Instance method to get the heartRate BPM informtion

    func getHeartRateBPM(_ characteristic: CBCharacteristic, error: Error?) {

    }

    // Instance method to get the manufacturers name

    func getManufacturerName(_ characteristic: CBCharacteristic, error: Error?) {
//      var manufacturerName = NSString(initWithData: characteristic.value, encoding: NSUTF8StringEncoding)
//      manufacturer = NSString(stringwithFormat: "Manufacturer: %@", manufacturerName)
//      return
    }

    // Instance method to get the device body location

    func getBodyLocation(characteristic: CBCharacteristic) {
        var sensorData: [NSData] = [characteristic.value! as NSData]

        let deviceBodyLocations: [Int: String] = [0: "Other",
                                                  1: "Chest",
                                                  2: "Wrist",
                                                  3: "Finger",
                                                  4: "Hand",
                                                  5: "Ear Lobe",
                                                  6: "Foot",
                                                  7: "Reserved"]
        
        let location: [Int] = sensorData[0]
        
        print("The device is located at the %@", deviceBodyLocations[location]!)
        
        }
    
