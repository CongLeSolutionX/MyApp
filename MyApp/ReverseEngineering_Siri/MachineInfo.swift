//
//  MachineInfo.swift
//  MyApp
//
//  Created by Cong Le on 11/30/24.
//

import Foundation


// MARK: - Helper Function to Retrieve System Information Using sysctl
func sysctlValue(for name: String) -> Int {
    var size = 0
    sysctlbyname(name, nil, &size, nil, 0)
    var value = 0
    sysctlbyname(name, &value, &size, nil, 0)
    return value
}

//// MARK: - Mach-O Magic Numbers
//enum Magic: UInt32 {
//    case _32BitMagic = 0xFEEDFACE   // Mach-O 32-bit format
//    case _64BitMagic = 0xFEEDFACF   // Mach-O 64-bit format
//    case _32BitCIGAM = 0xCEFAEDFE   // Mach-O 32-bit (big-endian)
//    case _64BitCIGAM = 0xCFFAEDFE   // Mach-O 64-bit (big-endian)
//}


// MARK: - CPU Type
enum CpuType: UInt32 {
    case i386 = 7
    case x86_64 = 0x1000007         // Composed using i386 | 0x1000000
    case arm = 12
    case arm64 = 0x100000C          // Composed using arm | 0x1000000
    case powerPC = 18
    case powerPC64 = 0x1000012      // Composed using powerPC | 0x1000000
}


// MARK: - Machine Info Struct
struct MachineInfo {
    let cpuType: CpuType
    let cpuSubType: UInt32
    let is64Bit: Bool
    let memorySize: UInt64

    static func current() -> MachineInfo {
        // Retrieve CPU type and subtype
        let cpuType = CpuType(rawValue: UInt32(sysctlValue(for: "hw.cputype"))) ?? .i386
        let cpuSubType = UInt32(sysctlValue(for: "hw.cpusubtype"))

        // Determine if the system is 64-bit
        let is64Bit = MemoryLayout<UInt>.size == 8

        // Retrieve total physical memory size
        var memorySize: UInt64 = 0
        var size = MemoryLayout.size(ofValue: memorySize)
        sysctlbyname("hw.memsize", &memorySize, &size, nil, 0)

        return MachineInfo(cpuType: cpuType, cpuSubType: cpuSubType, is64Bit: is64Bit, memorySize: memorySize)
    }

    func printInfo() {
        print("Machine Information:")
        print("CPU Type: \(cpuType)")
        print("CPU Subtype: \(cpuSubType)")
        print("Is 64-bit: \(is64Bit)")
        print("Memory Size: \(memorySize / (1024 * 1024)) MB") // Convert to MB
    }
}

// MARK: - Modified Mach-O Header with Dynamic Values
struct MachineInfoHeader {
    let magic: Magic                 // Magic number (32-bit, 64-bit, etc.)
    let machineDetails: MachineInfo  // Capturing the machine's runtime details
    let fileType: UInt32             // Mach-O file type (e.g., executable, library)
    let numCommands: UInt32          // Number of load commands
    let sizeOfCommands: UInt32       // Total size of load commands
    let flags: Flags                 // Bitfield of flags

    init(fileType: UInt32, numCommands: UInt32, sizeOfCommands: UInt32, flags: Flags) {
        let machineInfo = MachineInfo.current()

        // Dynamically determine the magic number based on CPU architecture
        let magic: Magic = machineInfo.is64Bit ? ._64BitMagic : ._32BitMagic

        self.magic = magic
        self.machineDetails = machineInfo
        self.fileType = fileType
        self.numCommands = numCommands
        self.sizeOfCommands = sizeOfCommands
        self.flags = flags
    }

    func printHeaderInfo() {
        print("Mach-O Header Information:")
        print("Magic Number: \(magic)")
        machineDetails.printInfo()
        print("File Type: \(fileType)")
        print("Number of Commands: \(numCommands)")
        print("Size of Load Commands: \(sizeOfCommands) bytes")
        print("Flags: \(flags)")
    }
}

// MARK: - Mach-O File Struct (Base Structure)
struct MachOFile {
    let header: MachineInfoHeader                   // Mach-O header
    var loadCommands: [LoadCommand]      // Array of load commands

    init(header: MachineInfoHeader, loadCommands: [LoadCommand]) {
        self.header = header
        self.loadCommands = loadCommands
    }

    func printMachOInfo() {
        header.printHeaderInfo()
        print("Load Commands:")
        for (index, command) in loadCommands.enumerated() {
            print("  Command \(index + 1): \(command.command) - Size: \(command.commandSize) bytes")
        }
    }
}
