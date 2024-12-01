//
//  NativeUIKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//

import UIKit

class NativeUIKitViewController: UIViewController {

    var customView: CustomView?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("NativeUIKitViewController viewDidLoad() called")
        view.backgroundColor = .white
//
//        // Initialize CustomView programmatically
//        let frame = CGRect(x: 50, y: 100, width: 200, height: 200)
//        customView = CustomView(frame: frame)
//        if let customView = customView {
//            view.addSubview(customView)
//        }
//
//        // Trigger layout and display updates after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.customView?.triggerLayout()
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.customView?.triggerDisplay()
//        }
//
//        // Remove the view after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            self.customView?.removeView()
//            self.customView = nil
//        }
        
        //demoSiri()
        demoDynamyLoadMachineInfo()
        
        //demoRunObjectCViewController()
        
    }
    
    
    
//    func demoSiri() {
//        
//        let header = MachineInfoHeader(
//            magic: ._64BitMagic,
//            cpuType: .arm64,
//            cpuSubType: 0,
//            fileType: 2,
//            numCommands: 5,
//            sizeOfCommands: 256,
//            flags: [.pie, .dyldLink]
//        )
//
//        let segmentCommand = CommandSegment64(
//            segmentName: "__TEXT",
//            vmAddress: 0x1000,
//            vmSize: 0x2000,
//            fileOffset: 0x0,
//            fileSize: 0x2000,
//            maxProt: 0x7,
//            initProt: 0x5,
//            numSections: 2,
//            flags: 0
//        )
//
//        let loadCommand = LoadCommand(
//            command: .segment64,
//            commandSize: 72,
//            data: segmentCommand
//        )
//
//        let machOFile = MachOFile(header: header, loadCommands: [loadCommand])
//
//        print(machOFile)
//
//
//    }
    
    
    func demoDynamyLoadMachineInfo() {
        
        // MARK: - Example Usage
        let header = MachineInfoHeader(
            fileType: 2,                // Simulated Mach-O file type (e.g., executable)
            numCommands: 5,             // Example number of commands
            sizeOfCommands: 256,        // Example size of commands
            flags: [.pie, .dyldLink]    // Example flags
        )
        
        let segmentCommand = CommandSegment64(
            segmentName: "__TEXT",
            vmAddress: 0x1000,          // These would usually be parsed or dynamically determined
            vmSize: 0x2000,
            fileOffset: 0x0,
            fileSize: 0x2000,
            maxProt: 0x7,
            initProt: 0x5,
            numSections: 2,
            flags: 0
        )
        
        let loadCommand = LoadCommand(
            command: .segment64,
            commandSize: 72,
            data: segmentCommand
        )
        
        let machOFile = MachOFile(header: header, loadCommands: [loadCommand])
        machOFile.printMachOInfo()
        
    }
    
    
    // Notes: Since ObjC code will compile at compiling time, not at runtime,
    // we need to compile the project on a simulator or a physical device to see Obj-C code run.
    // Presenting LifecycleViewController from another view controller
//    func demoRunObjectCViewController() {
//        let objCViewController = LifecycleViewController(nibName: nil, bundle: nil)
//        objCViewController.present(self, animated: true) {
//            NSLog("LifecycleViewController presented")
//        }
//    }
}
