//
//  Siri-reverse-engineering.swift
//  MyApp
//
//  Created by Cong Le on 11/30/24.
//
//
import Foundation

//// MARK: - CPU Type
//enum CpuType: UInt32 {
//    case i386 = 7
//    case x86_64 = 0x1000007         // Composed using i386 | 0x1000000
//    case arm = 12
//    case arm64 = 0x100000C          // Composed using arm | 0x1000000
//    case powerPC = 18
//    case powerPC64 = 0x1000012      // Composed using powerPC | 0x1000000
//}
//
//// MARK: - ARM Subtypes
//enum SubCpuTypeARM: UInt32 {
//    case v7 = 9                   // ARMv7
//    case v7F = 10                 // Cortex A9
//    case v7S = 11                 // Swift core
//    case v8 = 13                  // ARMv8
//}
//

// MARK: - Header Struct
struct Header {
    let magic: Magic                 // Magic number (32-bit, 64-bit, etc.)
    let cpuType: CpuType             // CPU type
    let cpuSubType: UInt32           // Specific CPU subtype
    let fileType: UInt32             // Mach-O file type (e.g., executable, library)
    let numCommands: UInt32          // Number of load commands
    let sizeOfCommands: UInt32       // Total size of load commands
    let flags: Flags                 // Bitfield of flags

    // Padding if necessary for 64-bit architecture
    let padding: UInt32?

    init(magic: Magic,
         cpuType: CpuType,
         cpuSubType: UInt32,
         fileType: UInt32,
         numCommands: UInt32,
         sizeOfCommands: UInt32,
         flags: Flags) {
        self.magic = magic
        self.cpuType = cpuType
        self.cpuSubType = cpuSubType
        self.fileType = fileType
        self.numCommands = numCommands
        self.sizeOfCommands = sizeOfCommands
        self.flags = flags

        // If 64-bit magic, add 4-byte padding
        self.padding = (magic == ._64BitMagic) ? 0 : nil
    }
}


//
//// MARK: - Mach-O Struct
//struct MachOFile {
//    let header: Header                   // Mach-O header
//    var loadCommands: [LoadCommand]      // Array of load commands
//
//    init(header: Header, loadCommands: [LoadCommand]) {
//        self.header = header
//        self.loadCommands = loadCommands
//    }
//}
