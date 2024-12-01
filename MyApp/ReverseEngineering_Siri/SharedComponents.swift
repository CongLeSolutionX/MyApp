//
//  SharedComponents.swift
//  MyApp
//
//  Created by Cong Le on 11/30/24.
//

import Foundation

// MARK: - Mach-O Magic Numbers
enum Magic: UInt32 {
    case _32BitMagic = 0xFEEDFACE   // Mach-O 32-bit format
    case _64BitMagic = 0xFEEDFACF   // Mach-O 64-bit format
    case _32BitCIGAM = 0xCEFAEDFE   // Mach-O 32-bit (big-endian)
    case _64BitCIGAM = 0xCFFAEDFE   // Mach-O 64-bit (big-endian)
}


// MARK: - Flags Bitfield
struct Flags: OptionSet {
    let rawValue: UInt32

    static let noUndefs     = Flags(rawValue: 1 << 0)
    static let incrLink      = Flags(rawValue: 1 << 1)
    static let dyldLink      = Flags(rawValue: 1 << 2)
    static let bindAtLoad    = Flags(rawValue: 1 << 3)
    static let prebound      = Flags(rawValue: 1 << 4)
    static let splitSegs     = Flags(rawValue: 1 << 5)
    static let lazyInit      = Flags(rawValue: 1 << 6)
    static let twoLevel      = Flags(rawValue: 1 << 7)
    static let forceFlat     = Flags(rawValue: 1 << 8)
    static let noMultiDefs   = Flags(rawValue: 1 << 9)
    static let noFixPrebinding = Flags(rawValue: 1 << 10)
    static let appExtensionSafe = Flags(rawValue: 1 << 11)
    static let pie           = Flags(rawValue: 1 << 12) // Position-independent executable
}

// MARK: - Load Command Enum
enum LoadTypeOfCommand: UInt32 {
    case segment = 0x1
    case symtab = 0x2
    case thread = 0x4
    case unixThread = 0x5
    case uuid = 0x1B
    case segment64 = 0x19
    case versionMinMacOSX = 0x24
    case versionMinIOS = 0x25
    case dyldInfo = 0x22
    case loadDylib = 0xC  // etc.
}

// MARK: - Load Command Struct
struct LoadCommand {
    let command: LoadTypeOfCommand         // Type of the command
    let commandSize: UInt32          // Size of the command

    // Associated data for specific commands
    var data: Any?

    init(command: LoadTypeOfCommand, commandSize: UInt32, data: Any? = nil) {
        self.command = command
        self.commandSize = commandSize
        self.data = data
    }
}

// MARK: - Segment Command 64-bit
struct CommandSegment64 {
    let segmentName: String          // 16-byte segment name
    let vmAddress: UInt64            // Virtual memory address
    let vmSize: UInt64               // Virtual memory size
    let fileOffset: UInt64           // Offset in the file
    let fileSize: UInt64             // File size
    let maxProt: UInt32              // Maximum VM protection
    let initProt: UInt32             // Initial VM protection
    let numSections: UInt32          // Number of sections
    let flags: UInt32                // Flags

    struct Section64 {
        let sectionName: String      // 16-byte section name
        let segmentName: String      // 16-byte segment name
        let address: UInt64          // Memory address of the section
        let size: UInt64             // Section size in memory
        let offset: UInt32           // Offset in file
        let align: UInt32            // Section alignment
        let relocationOffset: UInt32 // File offset of relocation entries
        let numRelocations: UInt32   // Number of relocation entries
        let flags: UInt32            // Section flags
        let reserved1: UInt32        // Reserved field
        let reserved2: UInt32        // Reserved field
    }
}



