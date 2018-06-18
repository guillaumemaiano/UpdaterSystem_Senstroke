//
//  UpdateSensorFirmwareViewController.swift
//  UpdaterSystem
//
//  Created by Guillaume MAIANO on 13/06/2018.
//  Copyright © 2018 REDISON. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBluetoothKit
import CoreBluetooth
import RxSwiftExt

struct Constants {

    struct UUID {

        /**
         // declares an Apple-compliant  custom BLE service for MIDI support
         // [https://developer.apple.com/library/content/qa/qa1831/](PDF)
         // [https://developer.apple.com/bluetooth/](Generic Bluetooth doc)
         */
        static let midiService = "03b80e5a-ede8-4b33-a751-6ce34ec4c700"
    }

    static let sensorStandardName = "Drumistic"
    static let companyName = "Redison"
}

class Senstroke {

    // cannot inherit from Peripheral because the class is not open
    var sensor: Peripheral?
    // unique device identifier
    @objc dynamic var uid = ""
    // display name
    @objc dynamic var name = ""

    convenience init(peripheral: Peripheral) {
        self.init()
        self.sensor = peripheral
        self.name = peripheral.name ?? "NOT NAMED"

    }
}

class SenstrokeManager {

    private var disposeBagSensors = DisposeBag()

    static let sharedInstance = SenstrokeManager()

    public let peripheralsViewModelObservable: Observable<[PeripheralCellViewModel]>

    // Declares Apple BLE MIDI service
    let serviceUUIDs = [
        CBUUID(string: Constants.UUID.midiService)
    ]

    // An observable that allows tracking the state so that the UI can warn the user if the system is currently shut down
    public let bluetoothStateObservable: Observable<BluetoothState>!

    // list of acceptable connected devices
    var connectedSenstrokes: Variable<[Senstroke]> = Variable([])
    // Might contain non-Senstroke devices if they're not properly named...
    var detectedDevices: Variable<[Senstroke]> = Variable([])

    init() {

        // setup the scan observable
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false] as [String: AnyObject]
        let bluetoothManager = CentralManager(queue: .main, options: options)

        peripheralsViewModelObservable = detectedDevices.asObservable()
            .map({ (devices) in
                return devices.map {PeripheralCellViewModel(device: $0) }
            }).share(replay: 1)

        // setup the bluetooth state system
        bluetoothStateObservable = bluetoothManager.observeState().share(replay: 1)
        // get the central manager object if it's "powered on" (available)
        let managerStateONObservable = bluetoothStateObservable.filter { $0 == .poweredOn }.share(replay: 1)
        // get the list of relevant peripherals (MIDI sensors)
        let scanPeripheralsObservable = managerStateONObservable
            .flatMap { _ -> Observable<ScannedPeripheral> in
                let observable = bluetoothManager
                    .scanForPeripherals(withServices: self.serviceUUIDs)
                return observable
        }
        scanPeripheralsObservable
            .filter {$0.peripheral.name == Constants.sensorStandardName}
            .subscribe(onNext: { [unowned self] (scannedperipheral) in
                self.detectedDevices.value.append(Senstroke(peripheral: scannedperipheral.peripheral))
            }).disposed(by: disposeBagSensors)



    }
}

class SenstrokeViewModel {

    private var disposeBag = DisposeBag()

    let senstrokeManager = SenstrokeManager()

    //Input
    public let rowSelected = PublishSubject<Int>()

    init() {

    }
}

// Device cells
// Cell Model
struct PeripheralCellViewModel {

    //Private
    public let device: Senstroke

    //Variable
    public let selected: Variable<Bool>

    //Output
    public let name: String

    init(device: Senstroke) {
        self.device = device
        name = device.name
        selected = Variable(device.sensor?.isConnected ?? false)
    }

    public func deviceUUID() -> String? {
        return self.device.sensor?.identifier.uuidString
    }
}
// Cell definition
class PeripheralCell: UITableViewCell {
    private var disposeBag = DisposeBag()

    @IBOutlet weak var nameLabel: UILabel!

    var viewModel: PeripheralCellViewModel! {
        didSet {
            bindViews()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    func bindViews() {
        self.nameLabel.text = self.viewModel.name
        self.viewModel.selected.asDriver().drive(onNext: { [unowned self] (selected) in
            self.accessoryType = selected ? .checkmark : .none
        }).disposed(by: self.disposeBag)
    }
}
class UpdateSensorFirmwareViewController: UITableViewController {

    //var viewModel = UpdateSensorFirmwareViewModel()

    var viewModel = SenstrokeViewModel()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = nil
        tableView.dataSource = nil
        bindViews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // - Rx-management private method
    private func bindViews() {

        viewModel.senstrokeManager.peripheralsViewModelObservable.bind(to: tableView.rx.items(cellIdentifier: "PeripheralCell", cellType: PeripheralCell.self)) { (_, model, cell) in
            cell.viewModel = model
            }.disposed(by: self.disposeBag)

        tableView.rx.itemSelected.map {$0.row}
            .bind(to: self.viewModel.rowSelected)
            .disposed(by: self.disposeBag)
    }

    /*
     // MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     Get the new view controller using segue.destinationViewController.
     Pass the selected object to the new view controller.
     }
     */

}
