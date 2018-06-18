//
//  SensorFirmwareUpdateManager.swift
//  UpdaterSystem
//
//  Created by guillaume MAIANO on 13/06/2018.
//  Copyright © 2018 REDISON. All rights reserved.
//

import Foundation
import iOSDFULibrary
import CoreBluetooth
import RxSwift
import RxCocoa
import RxBluetoothKit

class SensorFirmwareUpdateManager//: DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate
{

    static let sharedInstance = SensorFirmwareUpdateManager()

    private var isScanning = false

    let disposeBag = DisposeBag()

    init() {
//
////        centralManager  = CBCentralManager(delegate: self, queue: nil)
//
//        // build a url that directs to a firmware for testing
//        let url: URL! = URL(string: "http://redison.com/dev/testingFirmware")
//        selectedFirmware = DFUFirmware(urlToZipFile:url)
    }
//    func initiateUpdate() -> Observable<Int>{
////
////        let initiator = DFUServiceInitiator(centralManager: centralManager, target: dfuPeripheral).with(firmware: selectedFirmware!)
//        // Optional:
//        // initiator.forceDfu = true/false; // default false
//        // initiator.packetReceiptNotificationParameter = N; // default is 12
////        initiator.logger = self; // - to get log info
////        initiator.delegate = self; // - to be informed about current state and errors
////        initiator.progressDelegate = self; // - to show progress bar
//        // initiator.peripheralSelector = ... // the default selector is used
////
////        let controller = initiator.start()
//        return Observable(5)
//    }

}
