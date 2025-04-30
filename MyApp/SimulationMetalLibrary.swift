//
//  SimulationMetalLibrary.swift
//  MyApp
//
//  Created by Cong Le on 4/29/25.
//

import SwiftUI
import Combine // For ObservableObject

// MARK: - Metal API Enums (Directly from Docs) -

// Using actual Metal types if available allows for easier potential integration later,
// but for pure simulation, defining them locally avoids framework dependency.
// Let's define them locally for this simulation.

@available(iOS 10.0, *)
public enum MTLPatchType : UInt, CaseIterable, Hashable, Sendable {
    case none = 0
    case triangle = 1
    case quad = 2
    public static var allCases: [MTLPatchType] = [.none, .triangle, .quad] // Manually add for Picker
}

@available(iOS 8.0, *)
public enum MTLFunctionType : UInt, CaseIterable, Hashable, Sendable {
    case vertex = 1
    case fragment = 2
    case kernel = 3
    @available(iOS 14.0, *) case visible = 5
    @available(iOS 14.0, *) case intersection = 6
    @available(iOS 16.0, *) case mesh = 7
    @available(iOS 16.0, *) case object = 8

    // Manually add for Picker, considering availability
    public static var allCases: [MTLFunctionType] {
         var cases: [MTLFunctionType] = [.vertex, .fragment, .kernel]
         if #available(iOS 14.0, *) { cases.append(contentsOf: [.visible, .intersection]) }
         if #available(iOS 16.0, *) { cases.append(contentsOf: [.mesh, .object]) }
         return cases
     }

     var availableString: String {
         switch self {
         case .visible, .intersection: return " (iOS 14+)"
         case .mesh, .object: return " (iOS 16+)"
         default: return ""
         }
     }
}

@available(iOS 9.0, *)
public enum MTLLanguageVersion : UInt, CaseIterable, Hashable, Sendable {
    @available(iOS, introduced: 9.0, deprecated: 16.0, message: "Use a newer language standard")
    case version1_0 = 65536 // Deprecated
    case version1_1 = 65537 // iOS 9.0
    case version1_2 = 65538 // iOS 10.0
    case version2_0 = 131072 // iOS 11.0
    case version2_1 = 131073 // iOS 12.0
    case version2_2 = 131074 // iOS 13.0
    case version2_3 = 131075 // iOS 14.0
    case version2_4 = 131076 // iOS 15.0
    case version3_0 = 196608 // iOS 16.0
    case version3_1 = 196609 // iOS 17.0
    case version3_2 = 196610 // iOS 18.0

    public static var allCases: [MTLLanguageVersion] = [
         .version1_1, .version1_2, .version2_0, .version2_1, .version2_2, .version2_3,
         .version2_4, .version3_0, .version3_1, .version3_2
        // .version1_0 omitted due to deprecation for selection, but kept for definition
    ]

    var description: String {
        switch self {
            case .version1_0: return "1.0 (Deprecated)"
            case .version1_1: return "1.1 (iOS 9+)"
            case .version1_2: return "1.2 (iOS 10+)"
            case .version2_0: return "2.0 (iOS 11+)"
            case .version2_1: return "2.1 (iOS 12+)"
            case .version2_2: return "2.2 (iOS 13+)"
            case .version2_3: return "2.3 (iOS 14+)"
            case .version2_4: return "2.4 (iOS 15+)"
            case .version3_0: return "3.0 (iOS 16+)"
            case .version3_1: return "3.1 (iOS 17+)"
            case .version3_2: return "3.2 (iOS 18+)"
        }
    }
}

@available(iOS 14.0, *)
public enum MTLLibraryType : Int, CaseIterable, Hashable, Sendable {
    case executable = 0
    case dynamic = 1
    public static var allCases: [MTLLibraryType] = [.executable, .dynamic]
}

@available(iOS 16.0, *)
public enum MTLLibraryOptimizationLevel : Int, CaseIterable, Hashable, Sendable {
    case `default` = 0
    case size = 1
    public static var allCases: [MTLLibraryOptimizationLevel] = [.default, .size]
}

@available(iOS 16.4, *)
public enum MTLCompileSymbolVisibility : Int, CaseIterable, Hashable, Sendable {
    case `default` = 0
    case hidden = 1
    public static var allCases: [MTLCompileSymbolVisibility] = [.default, .hidden]
}

// @available not needed for enum definition itself if members using it are checked
public enum MTLMathMode : Int, CaseIterable, Hashable, Sendable {
    case safe = 0
    case relaxed = 1
    case fast = 2
    public static var allCases: [MTLMathMode] = [.safe, .relaxed, .fast]
}

public enum MTLMathFloatingPointFunctions : Int, CaseIterable, Hashable, Sendable {
    case fast = 0
    case precise = 1
     public static var allCases: [MTLMathFloatingPointFunctions] = [.fast, .precise]
}

// MARK: - Simulated Metal Data Structures -

struct SimulatedMTLVertexAttribute: Identifiable, Hashable {
    let id = UUID()
    var name: String = "attribute\(Int.random(in: 0...10))"
    var attributeIndex: Int = Int.random(in: 0...15)
    var attributeType: String = ["float4", "float3", "ushaort2"].randomElement()! // Simplified MTLDataType
    var isActive: Bool = true
    @available(iOS 10.0, *) var isPatchData: Bool = false
    @available(iOS 10.0, *) var isPatchControlPointData: Bool = false
}

@available(iOS 10.0, *)
struct SimulatedMTLAttribute: Identifiable, Hashable {
    let id = UUID()
    var name: String = "attr_\(Int.random(in: 0...10))"
    var attributeIndex: Int = Int.random(in: 0...30)
    var attributeType: String = ["float", "half", "uint"].randomElement()! // Simplified MTLDataType
    var isActive: Bool = true
    var isPatchData: Bool = false
    var isPatchControlPointData: Bool = false
}

@available(iOS 10.0, *)
struct SimulatedMTLFunctionConstant: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var type: String = ["uint", "bool", "float"].randomElement()! // Simplified MTLDataType
    var index: Int
    var required: Bool = false
}

// Simple struct to hold key-value pairs for function constant specialization
struct SimulatedMTLFunctionConstantValues {
    var valuesByName: [String: String] = [:] // Simplified value to String for simulation
    // valuesByIndex could also be added if needed
}

// A basic representation, actual MTLFunctionOptions is likely more complex
struct MTLFunctionOptions: OptionSet {
    let rawValue: Int
    static let none = MTLFunctionOptions(rawValue: 1 << 0)
    // ... other options if known ...
}

// MARK: - Simulated Error Type -

// Mirroring the structure from the docs
let SimulatedMTLLibraryErrorDomain = "SimulatedMTLLibraryErrorDomain"

enum SimulatedMTLLibraryError: Error, CustomNSError, Hashable {
    case unsupported
    case `internal`
    case compileFailure(details: String)
    case compileWarning(details: String)
    @available(iOS 10.0, *) case functionNotFound(name: String)
    @available(iOS 10.0, *) case fileNotFound(path: String)

    static var errorDomain: String { SimulatedMTLLibraryErrorDomain }

    var errorCode: Int {
        switch self {
        case .unsupported: return 1
        case .internal: return 2
        case .compileFailure: return 3
        case .compileWarning: return 4
        case .functionNotFound: return 5
        case .fileNotFound: return 6
        }
    }

    var errorUserInfo: [String : Any] {
        var info: [String: Any] = [:]
        switch self {
        case .compileFailure(let details), .compileWarning(let details):
            info[NSLocalizedDescriptionKey] = details
        case .functionNotFound(let name):
            info[NSLocalizedDescriptionKey] = "Function '\(name)' not found."
        case .fileNotFound(let path):
            info[NSLocalizedDescriptionKey] = "File not found at path: \(path)"
        default:
            info[NSLocalizedDescriptionKey] = String(describing: self)
        }
        return info
    }
}

// MARK: - Simulated Metal Compile Options -

// Class to mimic MTLCompileOptions, conforming to NSObject/NSCopying
final class SimulatedMTLCompileOptions: NSObject, NSCopying, ObservableObject {
    @Published var preprocessorMacros: [String : String]? = ["DEBUG": "1", "TEXTURE_COUNT": "4"] // Simplified value
    @available(iOS, introduced: 8.0, deprecated: 18.0, message: "Use mathMode instead")
    @Published var fastMathEnabled: Bool = true {
        didSet {
            // Keep mathMode roughly in sync for simulation unless explicitly set
            if fastMathEnabled && mathMode != .fast && mathMode != .relaxed { mathMode = .fast }
            if !fastMathEnabled && mathMode != .safe { mathMode = .safe }
        }
    }
    @available(iOS 18.0, *) @Published var mathMode: MTLMathMode = .fast
    @available(iOS 18.0, *) @Published var mathFloatingPointFunctions: MTLMathFloatingPointFunctions = .fast
    @available(iOS 9.0, *) @Published var languageVersion: MTLLanguageVersion = .version3_1
    @available(iOS 14.0, *) @Published var libraryType: MTLLibraryType = .executable
    @available(iOS 14.0, *) @Published var installName: String? = nil
    @available(iOS 14.0, *) @Published var libraries: [String]? = [] // Simplified to names/paths
    @available(iOS 14.0, *) @Published var preserveInvariance: Bool = false
    @available(iOS 16.0, *) @Published var optimizationLevel: MTLLibraryOptimizationLevel = .default
    @available(iOS 16.4, *) @Published var compileSymbolVisibility: MTLCompileSymbolVisibility = .default
    @available(iOS 16.4, *) @Published var allowReferencingUndefinedSymbols: Bool = false
    @available(iOS 16.4, *) @Published var maxTotalThreadsPerThreadgroup: Int = 1024
    @available(iOS 18.0, *) @Published var enableLogging: Bool = false

    override init() {
        super.init()
    }

    // NSCopying implementation (creates a new instance with copied values)
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SimulatedMTLCompileOptions()
        copy.preprocessorMacros = self.preprocessorMacros
        copy.fastMathEnabled = self.fastMathEnabled
        if #available(iOS 18.0, *) {
             copy.mathMode = self.mathMode
             copy.mathFloatingPointFunctions = self.mathFloatingPointFunctions
        }
        if #available(iOS 9.0, *) {
             copy.languageVersion = self.languageVersion
        }
        if #available(iOS 14.0, *) {
             copy.libraryType = self.libraryType
             copy.installName = self.installName
             copy.libraries = self.libraries
             copy.preserveInvariance = self.preserveInvariance
        }
        if #available(iOS 16.0, *) {
             copy.optimizationLevel = self.optimizationLevel
        }
         if #available(iOS 16.4, *) {
             copy.compileSymbolVisibility = self.compileSymbolVisibility
             copy.allowReferencingUndefinedSymbols = self.allowReferencingUndefinedSymbols
             copy.maxTotalThreadsPerThreadgroup = self.maxTotalThreadsPerThreadgroup
         }
         if #available(iOS 18.0, *) {
              copy.enableLogging = self.enableLogging
         }
        return copy
    }
}

// MARK: - Simulated Metal Protocols -

protocol SimulatedMTLDevice {
    // Simplified device representation
    var name: String { get }
    func makeLibrary(source: String, options: SimulatedMTLCompileOptions?) throws -> any SimulatedMTLLibrary
    func makeLibraryAsync(source: String, options: SimulatedMTLCompileOptions?) async throws -> any SimulatedMTLLibrary // Added for demo
    // Other device methods omitted...
}

protocol SimulatedMTLArgumentEncoder {
    var label: String? { get set }
    var device: SimulatedMTLDevice { get }
    var encodedLength: Int { get }
    // ... other methods omitted ...
}

protocol SimulatedMTLFunction: Identifiable {
    var id: UUID { get } // Make identifiable for SwiftUI lists
    var label: String? { get set }
    var device: SimulatedMTLDevice { get }
    var functionType: MTLFunctionType { get }
    @available(iOS 10.0, *) var patchType: MTLPatchType { get }
    @available(iOS 10.0, *) var patchControlPointCount: Int { get }
    var vertexAttributes: [SimulatedMTLVertexAttribute]? { get }
    @available(iOS 10.0, *) var stageInputAttributes: [SimulatedMTLAttribute]? { get }
    var name: String { get }
    @available(iOS 10.0, *) var functionConstantsDictionary: [String : SimulatedMTLFunctionConstant] { get }
    @available(iOS 14.0, *) var options: MTLFunctionOptions { get }
    var specializationNote: String? { get } // Added for simulation clarity

    @available(iOS 11.0, *) func makeArgumentEncoder(bufferIndex: Int) -> SimulatedMTLArgumentEncoder
}

protocol SimulatedMTLLibrary: Identifiable {
    var id: UUID { get } // Make identifiable for SwiftUI lists
    var label: String? { get set }
    var device: SimulatedMTLDevice { get }
    var functionNames: [String] { get }
    @available(iOS 14.0, *) var type: MTLLibraryType { get }
    @available(iOS 14.0, *) var installName: String? { get }

    func makeFunction(name functionName: String) -> (any SimulatedMTLFunction)?

    @available(iOS 10.0, *)
    func makeFunction(name: String, constantValues: SimulatedMTLFunctionConstantValues) throws -> any SimulatedMTLFunction

    // Add async version for simulation
    @available(iOS 10.0, *)
    func makeFunctionAsync(name: String, constantValues: SimulatedMTLFunctionConstantValues) async throws -> any SimulatedMTLFunction
}

// MARK: - Mock Implementations -

class MockMTLDevice: SimulatedMTLDevice {
    let name: String = "Simulated GPU"
    private var libraryCache: [String: any SimulatedMTLLibrary] = [:] // Simulate caching

    // Synchronous library creation simulation
    func makeLibrary(source: String, options: SimulatedMTLCompileOptions?) throws -> any SimulatedMTLLibrary {
        print("Simulating synchronous library creation for source: \(source.prefix(30))...")
        // Simulate potential compilation error based on source content or options
        if source.contains("ERROR") {
            print("--> Simulated Compile Error!")
            throw SimulatedMTLLibraryError.compileFailure(details: "Syntax error in shader source near 'ERROR'")
        }
        // Simulate file not found if options suggest it
        if options?.libraryType == .dynamic && source == "nonexistent.mtllip" {
             print("--> Simulated File Not Found Error!")
            if #available(iOS 10.0, *) {
                 throw SimulatedMTLLibraryError.fileNotFound(path: source)
            } else {
                 throw SimulatedMTLLibraryError.internal // Fallback for older OS simulation
            }
        }

        // Create a mock library
        let mockLibrary = MockMTLLibrary(device: self, options: options)
        mockLibrary.label = options?.installName ?? "DefaultLib_\(UUID().uuidString.prefix(4))"
        libraryCache[mockLibrary.label!] = mockLibrary // Cache it maybe

        // Populate with some default functions based on options/source
        if options?.libraryType == .executable || options == nil {
           mockLibrary.addMockFunction(name: "vertex_main", type: .vertex)
           mockLibrary.addMockFunction(name: "fragment_main", type: .fragment)
           mockLibrary.addMockFunction(name: "compute_kernel", type: .kernel)
           mockLibrary.addMockFunction(name: "special_func_with_constants", type: .kernel, constants: ["ITERATIONS": 0, "THRESHOLD": 1])
            if #available(iOS 16.0, *) {
                 if source.contains("MESH_SHADER") {
                     mockLibrary.addMockFunction(name: "mesh_main", type: .mesh)
                 }
            }
        } else { // Dynamic library has no qualified functions
            mockLibrary.functionNames = [] // Clear default function names
            print("--> Created Dynamic Library (no qualified functions)")
        }

        print("--> Library creation successful: \(mockLibrary.label ?? "Untitled")")
        return mockLibrary
    }

    // Asynchronous library creation simulation
    func makeLibraryAsync(source: String, options: SimulatedMTLCompileOptions?) async throws -> any SimulatedMTLLibrary {
        print("Simulating ASYNCHRONOUS library creation for source: \(source.prefix(30))...")
        // Simulate compilation time
        try await Task.sleep(nanoseconds: UInt64(1.5 * 1_000_000_000)) // 1.5 seconds delay
        return try makeLibrary(source: source, options: options) // Call sync version after delay
    }
}

// Simple mock argument encoder
struct MockMTLArgumentEncoder: SimulatedMTLArgumentEncoder {
    var label: String?
    let device: SimulatedMTLDevice
    var encodedLength: Int = Int.random(in: 64...256) // Dummy length
}

class MockMTLFunction: SimulatedMTLFunction, ObservableObject {
    let id = UUID()
    @Published var label: String?
    let device: SimulatedMTLDevice
    let functionType: MTLFunctionType
    @available(iOS 10.0, *) var patchType: MTLPatchType = .none
    @available(iOS 10.0, *) var patchControlPointCount: Int = -1
    var vertexAttributes: [SimulatedMTLVertexAttribute]?
    @available(iOS 10.0, *) var stageInputAttributes: [SimulatedMTLAttribute]?
    let name: String
    @available(iOS 10.0, *) var functionConstantsDictionary: [String : SimulatedMTLFunctionConstant] = [:]
    @available(iOS 14.0, *) var options: MTLFunctionOptions = .none
    @Published var specializationNote: String? // Added for simulation feedback

    init(name: String, type: MTLFunctionType, device: SimulatedMTLDevice, constants: [String: Int] = [:]) {
        self.name = name
        self.functionType = type
        self.device = device
        self.label = name // Default label

        // Populate with dummy data based on type
        if type == .vertex {
            vertexAttributes = [
                SimulatedMTLVertexAttribute(name: "position", attributeIndex: 0, attributeType: "float4", isActive: true),
                SimulatedMTLVertexAttribute(name: "texCoord", attributeIndex: 1, attributeType: "float2", isActive: true)
            ]
        }
        if type == .fragment {
            if #available(iOS 10.0, *) {
                stageInputAttributes = [
                    SimulatedMTLAttribute(name: "v_color", attributeIndex: 0, attributeType: "half4", isActive: true)
                ]
            }
        }
        if #available(iOS 10.0, *) {
            for (constName, index) in constants {
                 functionConstantsDictionary[constName] = SimulatedMTLFunctionConstant(name: constName, index: index)
            }
        }
    }

    @available(iOS 11.0, *)
    func makeArgumentEncoder(bufferIndex: Int) -> SimulatedMTLArgumentEncoder {
        print("Simulating makeArgumentEncoder for function '\(name)' at buffer index \(bufferIndex)")
        return MockMTLArgumentEncoder(label: "\(name)_Encoder_\(bufferIndex)", device: device)
    }
}

class MockMTLLibrary: SimulatedMTLLibrary, ObservableObject {
    let id = UUID()
    @Published var label: String?
    let device: SimulatedMTLDevice
    @Published var functionNames: [String] = []
    @Published var type: MTLLibraryType = .executable
    @Published var installName: String?

    // Store the options used to create this library for inspection
    let creationOptions: SimulatedMTLCompileOptions?
    private var availableFunctions: [String: MockMTLFunction] = [:]

    init(device: SimulatedMTLDevice, options: SimulatedMTLCompileOptions? = nil) {
        self.device = device
        self.creationOptions = options?.copy() as? SimulatedMTLCompileOptions // Store a copy
        if #available(iOS 14.0, *) {
             self.type = options?.libraryType ?? .executable
             self.installName = options?.installName
        }
        self.label = "Lib_\(id.uuidString.prefix(6))"
    }

    // Helper to add mock functions during creation
    func addMockFunction(name: String, type: MTLFunctionType, constants: [String: Int] = [:]) {
         if !functionNames.contains(name) {
             functionNames.append(name)
         }
         availableFunctions[name] = MockMTLFunction(name: name, type: type, device: device, constants: constants)
    }

    func makeFunction(name functionName: String) -> (any SimulatedMTLFunction)? {
        print("Library '\(label ?? "Default")': Requesting function '\(functionName)'")
        guard let function = availableFunctions[functionName] else {
             print("--> Function '\(functionName)' not found in this library.")
             return nil
        }
        // Return a copy or new instance if mutation is expected downstream,
        // but for this simulation, returning the cached one is fine.
        print("--> Function '\(functionName)' found.")
        return function
    }

    @available(iOS 10.0, *)
    func makeFunction(name: String, constantValues: SimulatedMTLFunctionConstantValues) throws -> any SimulatedMTLFunction {
        print("Library '\(label ?? "Default")': Requesting function '\(name)' with specialization constants:")
        constantValues.valuesByName.forEach { print("  \($0.key): \($0.value)") }

        guard let baseFunction = availableFunctions[name] else {
            print("--> Error: Base function '\(name)' not found for specialization.")
            throw SimulatedMTLLibraryError.functionNotFound(name: name)
        }

        // Simulate creating a *new* specialized function instance
        let specializedFunction = MockMTLFunction(name: baseFunction.name, type: baseFunction.functionType, device: baseFunction.device, constants: baseFunction.functionConstantsDictionary.mapValues { $0.index }) // Start from base constants if any
        specializedFunction.label = baseFunction.label ?? baseFunction.name + " (Specialized)"

        // Apply constants - In reality, this triggers recompilation/linking with values baked in.
        // We just add a note here.
        let notes = constantValues.valuesByName.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        specializedFunction.specializationNote = "Specialized with: \(notes)"

         // Check if required constants are provided (simple simulation)
         for (constName, constantDef) in specializedFunction.functionConstantsDictionary {
             if constantDef.required && constantValues.valuesByName[constName] == nil {
                 print("--> Error: Required constant '\(constName)' missing for specialization.")
                 throw SimulatedMTLLibraryError.compileFailure(details: "Missing required function constant '\(constName)'")
             }
         }

        print("--> Specialized function '\(name)' created.")
        return specializedFunction
    }

     @available(iOS 10.0, *)
    func makeFunctionAsync(name: String, constantValues: SimulatedMTLFunctionConstantValues) async throws -> any SimulatedMTLFunction {
         print("Library '\(label ?? "Default")': Requesting ASYNC function '\(name)' with specialization...")
         // Simulate compilation/specialization time
         try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000)) // 0.5 seconds delay
         return try makeFunction(name: name, constantValues: constantValues) // Call sync version after delay
     }
}

// MARK: - SwiftUI Views -

struct HeaderText: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.vertical, 5)
    }
}

struct DetailRow: View {
     let label: String
     let value: String
     var body: some View {
         HStack {
             Text("\(label):").bold().frame(minWidth: 120, alignment: .trailing)
             Text(value)
             Spacer()
         }
         .font(.footnote)
     }
}

struct CompileOptionsView: View {
    @ObservedObject var options: SimulatedMTLCompileOptions

    var body: some View {
        VStack(alignment: .leading) {
             HeaderText(title: "MTLCompileOptions")

             DetailRow(label: "Macros", value: "\(options.preprocessorMacros?.count ?? 0) defined") // Simplified view
            Toggle("Fast Math", isOn: $options.fastMathEnabled)
                .padding(.leading, 130)
                 .disabled(true) // Show deprecated state
            Text("(Deprecated 18.0)").font(.caption).foregroundColor(.orange).padding(.leading, 130)

             if #available(iOS 18.0, *) {
                 Picker("Math Mode", selection: $options.mathMode) {
                      ForEach(MTLMathMode.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                  }
                  Picker("FP Functions", selection: $options.mathFloatingPointFunctions) {
                      ForEach(MTLMathFloatingPointFunctions.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                  }
             } else {
                  DetailRow(label: "Math Mode", value: "iOS 18+ Required")
                  DetailRow(label: "FP Functions", value: "iOS 18+ Required")
             }

             if #available(iOS 9.0, *) {
                 Picker("Language", selection: $options.languageVersion) {
                     ForEach(MTLLanguageVersion.allCases, id: \.self) { version in
                         Text(version.description).tag(version)
                     }
                 }
             } else {
                 DetailRow(label: "Language", value: "iOS 9+ Required")
             }

             if #available(iOS 14.0, *) {
                 Picker("Library Type", selection: $options.libraryType) {
                      ForEach(MTLLibraryType.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                  }
                 HStack {
                     Text("Install Name:").bold().frame(width: 120, alignment: .trailing)
                     TextField("Optional Path", text: Binding(get: { options.installName ?? "" }, set: { options.installName = $0.isEmpty ? nil : $0 }))
                         .textFieldStyle(.roundedBorder)
                 }.disabled(options.libraryType != .dynamic)
                 DetailRow(label: "Linked Libs", value: "\(options.libraries?.count ?? 0) linked") // Simplified
                 Toggle("Preserve Invariance", isOn: $options.preserveInvariance).padding(.leading, 130)
             } else {
                 DetailRow(label: "Library Type", value: "iOS 14+ Required")
                 DetailRow(label: "Install Name", value: "iOS 14+ Required")
                 DetailRow(label: "Linked Libs", value: "iOS 14+ Required")
                 DetailRow(label: "Preserve Inv.", value: "iOS 14+ Required")
             }

             if #available(iOS 16.0, *) {
                  Picker("Optimization", selection: $options.optimizationLevel) {
                       ForEach(MTLLibraryOptimizationLevel.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                   }
             } else {
                 DetailRow(label: "Optimization", value: "iOS 16+ Required")
             }

            if #available(iOS 16.4, *) {
                 Picker("Symbol Visibility", selection: $options.compileSymbolVisibility) {
                      ForEach(MTLCompileSymbolVisibility.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                  }
                Toggle("Allow Undefined Symbols", isOn: $options.allowReferencingUndefinedSymbols).padding(.leading, 130)
                 HStack {
                     Text("Max Threads/TG:").bold().frame(minWidth: 120, alignment: .trailing)
                     TextField("Value", value: $options.maxTotalThreadsPerThreadgroup, formatter: NumberFormatter())
                         .keyboardType(.numberPad)
                         .textFieldStyle(.roundedBorder)
                         .frame(width: 80)
                     Spacer()
                 }
            } else {
                 DetailRow(label: "Symbol Visibility", value: "iOS 16.4+ Required")
                 DetailRow(label: "Allow Undef.", value: "iOS 16.4+ Required")
                 DetailRow(label: "Max Threads", value: "iOS 16.4+ Required")
             }

            if #available(iOS 18.0, *) {
                Toggle("Enable Logging", isOn: $options.enableLogging).padding(.leading, 130)
            } else {
                 DetailRow(label: "Enable Logging", value: "iOS 18+ Required")
            }
        } // VStack
        .pickerStyle(.menu)
    }
}

struct LibraryDetailView: View {
    @ObservedObject var library: MockMTLLibrary // Use Mock for @ObservedObject
    @Binding var selectedFunction: (any SimulatedMTLFunction)?
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingSpecialization = false

    var body: some View {
        VStack(alignment: .leading) {
            HeaderText(title: "Selected MTLLibrary Details")
            DetailRow(label: "Label", value: library.label ?? "N/A")
            DetailRow(label: "Device", value: library.device.name)
            if #available(iOS 14.0, *) {
                DetailRow(label: "Type", value: String(describing: library.type))
                DetailRow(label: "Install Name", value: library.installName ?? "N/A")
            } else {
                 DetailRow(label: "Type", value: "N/A (iOS 14+)")
                 DetailRow(label: "Install Name", value: "N/A (iOS 14+)")
            }
            Divider()
            HeaderText(title: "Functions (\(library.functionNames.count))")
             List(library.functionNames, id: \.self) { funcName in
                 Button(funcName) {
                    selectedFunction = library.makeFunction(name: funcName)
                    if selectedFunction == nil {
                         showError( SimulatedMTLLibraryError.functionNotFound(name: funcName))
                    }
                 }
             }
             // Button to demonstrate specialization
             if let currentFunc = selectedFunction, !currentFunc.functionConstantsDictionary.isEmpty {
                  Button("Specialize '\(currentFunc.name)'") {
                      specializeFunction(currentFunc)
                  }
                  .padding(.top)
                  .disabled(isLoadingSpecialization)
                  .overlay {
                      if isLoadingSpecialization { ProgressView() }
                  }
             }

        }
        .alert("Error", isPresented: $showErrorAlert) {
             Button("OK") { }
         } message: {
             Text(alertMessage)
         }
    }

    private func specializeFunction(_ baseFunction: any SimulatedMTLFunction) {
        guard #available(iOS 10.0, *), !baseFunction.functionConstantsDictionary.isEmpty else { return }

        isLoadingSpecialization = true
        Task {
             // Simulate getting some runtime values for constants
              var constantValues = SimulatedMTLFunctionConstantValues()
              for (name, _) in baseFunction.functionConstantsDictionary {
                  constantValues.valuesByName[name] = name == "ITERATIONS" ? "10" : "0.5" // Dummy values
              }

            do {
                let specializedFunc = try await library.makeFunctionAsync(name: baseFunction.name, constantValues: constantValues)
                selectedFunction = specializedFunc // Update the view with the specialized one
                print("Successfully created specialized function.")
            } catch let error as SimulatedMTLLibraryError {
                 showError(error)
                 print("Error specializing function: \(error)")
            } catch {
                 showError(SimulatedMTLLibraryError.internal)
                 print("Unknown error specializing function: \(error)")
            }
            isLoadingSpecialization = false
        }
    }

    private func showError(_ error: SimulatedMTLLibraryError) {
         alertMessage = error.localizedDescription
         showErrorAlert = true
    }
}

struct FunctionDetailView: View {
     @ObservedObject var function: MockMTLFunction // Use Mock type for @ObservedObject

     var body: some View {
         VStack(alignment: .leading) {
             HeaderText(title: "Selected MTLFunction Details")
             DetailRow(label: "Name", value: function.name)
             DetailRow(label: "Label", value: function.label ?? "N/A")
             DetailRow(label: "Function Type", value: String(describing: function.functionType) + function.functionType.availableString)

              if let note = function.specializationNote {
                  Text(note).font(.caption).foregroundColor(.purple).padding(.vertical, 2)
              }

             if #available(iOS 10.0, *) {
                 DetailRow(label: "Patch Type", value: String(describing: function.patchType))
                 DetailRow(label: "Patch Control Pts", value: function.patchControlPointCount >= 0 ? "\(function.patchControlPointCount)" : "N/A")
             } else {
                 DetailRow(label: "Patch Info", value: "N/A (iOS 10+)")
             }

             if let attributes = function.vertexAttributes, !attributes.isEmpty {
                 Divider()
                 HeaderText(title: "Vertex Attributes")
                 ForEach(attributes) { attr in
                     HStack {
                         Text("\(attr.attributeIndex):").bold()
                         Text(attr.name)
                         Text("(\(attr.attributeType))")
                     }
                     .font(.caption)
                     .padding(.leading)
                 }
             }

             if #available(iOS 10.0, *) {
                  if let attributes = function.stageInputAttributes, !attributes.isEmpty {
                     Divider()
                     HeaderText(title: "Stage Input Attributes")
                     ForEach(attributes) { attr in
                         HStack {
                             Text("\(attr.attributeIndex):").bold()
                             Text(attr.name)
                             Text("(\(attr.attributeType))")
                         }
                         .font(.caption)
                         .padding(.leading)
                     }
                 }

                 if !function.functionConstantsDictionary.isEmpty {
                     Divider()
                     HeaderText(title: "Function Constants")
                      ForEach(function.functionConstantsDictionary.sorted(by: { $0.value.index < $1.value.index }), id: \.key) { key, constant in
                          HStack {
                              Text("\(constant.index):").bold()
                              Text(constant.name)
                              Text("(\(constant.type)\(constant.required ? ", required" : ""))")
                          }
                          .font(.caption)
                          .padding(.leading)
                      }
                 }
             } else {
                  DetailRow(label: "Stage/Constants", value: "N/A (iOS 10+)")
             }

             if #available(iOS 11.0, *) {
                 Button("Make Argument Encoder (Idx 0)") {
                     let encoder = function.makeArgumentEncoder(bufferIndex: 0)
                     print("Created Encoder: \(encoder.label ?? "?"), Length: \(encoder.encodedLength)")
                     // In a real app, you'd use this encoder
                 }
                 .padding(.top)
             }

             Spacer() // Push content to top
         }
         .padding()
     }
}

// MARK: - Main Content View -

struct ContentView: View {
    @StateObject private var compileOptions = SimulatedMTLCompileOptions()
    @State private var mockDevice = MockMTLDevice()

    @State private var shaderSource: String = """
    #include <metal_stdlib>
    using namespace metal;

    struct VertexOut { float4 pos [[position]]; float2 uv; };

    vertex VertexOut vertex_main(uint vid [[vertex_id]]) { /* ... */ }
    fragment float4 fragment_main(VertexOut vo [[stage_in]]) { /* ... */ }
    kernel void compute_kernel(uint tid [[thread_position_in_grid]]) { /* ... */ }
    // Add 'ERROR' below to test compile failure simulation
    // SYNTAX ERROR HERE
    // Add 'MESH_SHADER' to test mesh function detection (iOS 16+)
    // #include <mesh_types>
    """
    @State private var createdLibrary: (any SimulatedMTLLibrary)? = nil
    @State private var selectedFunction: (any SimulatedMTLFunction)? = nil
    @State private var isLoadingLibrary = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            List {
                Section("Compile Options") {
                    CompileOptionsView(options: compileOptions)
                }

                Section("Shader Source (Simplified)") {
                    TextEditor(text: $shaderSource)
                        .frame(height: 150)
                        .font(.system(.footnote, design: .monospaced))
                        .border(Color.gray.opacity(0.5))
                }

                Section("Library Creation") {
                     Button(isLoadingLibrary ? "Creating..." : "Create Library Async") {
                         createLibrary()
                     }
                     .disabled(isLoadingLibrary)
                     .frame(maxWidth: .infinity, alignment: .center)

                    if let errMsg = errorMessage {
                        Text("Error: \(errMsg)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                if let library = createdLibrary {
                     Section("Created Library") {
                         // Cast to Mock for ObservableObject features in detail view
                         if let mockLib = library as? MockMTLLibrary {
                             LibraryDetailView(library: mockLib, selectedFunction: $selectedFunction)
                         } else {
                              Text("Library created, but cannot display details (type mismatch).") // Fallback
                         }
                     }
                 }

                 if selectedFunction != nil {
                     Section("Selected Function") {
                          // Cast to Mock for ObservableObject features in detail view
                          if let mockFunc = selectedFunction as? MockMTLFunction {
                             FunctionDetailView(function: mockFunc)
                          } else {
                               Text("Function selected, but cannot display details (type mismatch).") // Fallback
                          }
                      }
                  }

            } // List
            .navigationTitle("Metal API Simulation")
            .listStyle(.grouped)
        } // NavigationView
    }

    func createLibrary() {
        isLoadingLibrary = true
        errorMessage = nil
        createdLibrary = nil // Clear previous results
        selectedFunction = nil

        Task {
            do {
                // Grab a *copy* of the options at the time of creation
                let optionsCopy = compileOptions.copy() as! SimulatedMTLCompileOptions
                let library = try await mockDevice.makeLibraryAsync(source: shaderSource, options: optionsCopy)
                createdLibrary = library
            } catch let error as SimulatedMTLLibraryError {
                 errorMessage = error.localizedDescription
                 print("Library Creation Error: \(error)")
            } catch {
                 errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                 print("Unexpected Library Creation Error: \(error)")
            }
            isLoadingLibrary = false
        }
    }
}

// MARK: - App Entry Point -

@main
struct MetalSimulationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
