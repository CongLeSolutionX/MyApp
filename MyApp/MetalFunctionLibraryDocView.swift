//
//  MetalFunctionLibraryDocView.swift
//  MyApp
//
//  Created by Cong Le on 4/29/25.
//

import SwiftUI

// MARK: - Core Type Representation Views

/// Represents a property within a Metal type definition.
struct PropertyView: View {
    let name: String
    let type: String
    let availability: String?
    let deprecated: String?

    var body: some View {
        HStack(alignment: .top) {
            Text("\(name):").bold().frame(minWidth: 150, alignment: .leading) // Align property names
            VStack(alignment: .leading) {
                Text(type)
                if let availability = availability {
                    Text(availability).font(.caption).foregroundColor(.gray)
                }
                if let deprecated = deprecated {
                    Text("Deprecated: \(deprecated)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .strikethrough(color: .orange)

                }
            }
            Spacer() // Push content to the left
        }
        .padding(.vertical, 1)
    }
}

/// Represents a method signature within a Metal type definition.
struct MethodView: View {
    let signature: String
    let availability: String?
    let deprecated: String?

    var body: some View {
         VStack(alignment: .leading) {
             Text(signature).font(.system(.body, design: .monospaced)) // Monospaced for signature
             if let availability = availability {
                 Text(availability).font(.caption).foregroundColor(.gray)
             }
             if let deprecated = deprecated {
                 Text("Deprecated: \(deprecated)")
                     .font(.caption)
                     .foregroundColor(.orange)
                     .strikethrough(color: .orange)
             }
         }
         .padding(.vertical, 2)
    }
}

/// Represents an enumeration case.
struct EnumCaseView: View {
    let name: String
    let value: String?
    let availability: String?
    let deprecated: String?

    var body: some View {
        HStack(alignment: .top) {
            Text(".\(name)")
            if let value = value {
                Text("= \(value)")
            }
            Spacer()
            VStack(alignment: .trailing) {
                 if let availability = availability {
                     Text(availability).font(.caption).foregroundColor(.gray)
                 }
                 if let deprecated = deprecated {
                     Text("Deprecated: \(deprecated)")
                         .font(.caption)
                         .foregroundColor(.orange)
                         .strikethrough(color: .orange)
                 }
            }
        }
        .padding(.leading)
    }
}

// MARK: - Main Visualization View

struct MetalDocsSwiftUIView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Metal API Concepts in SwiftUI")
                    .font(.largeTitle)
                    .padding(.bottom)

                Text("This view visualizes elements from the Metal framework (Functions, Libraries, Compile Options) using SwiftUI layouts. It's for understanding structure, not execution.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom)

                // MARK: - Type Aliases
                 GroupBox("Type Aliases") {
                    VStack(alignment: .leading) {
                         HStack {
                            Text("MTLAutoreleasedArgument").bold()
                            Text("=")
                            Text("MTLArgument")
                         }
                         Text("iOS 8.0+, Deprecated 16.0: Use MTLBinding and cast...")
                             .font(.caption).foregroundColor(.orange)
                             .strikethrough(color: .orange)

                    }
                 }

                // MARK: - Enumerations
                 GroupBox("Enumerations") {
                    VStack(alignment: .leading, spacing: 10) {
                        EnumDefinitionView(
                            name: "MTLPatchType",
                            availability: "iOS 10.0+",
                            conformances: ["UInt", "@unchecked Sendable"],
                            cases: [
                                EnumCaseView(name: "none", value: "0"),
                                EnumCaseView(name: "triangle", value: "1"),
                                EnumCaseView(name: "quad", value: "2")
                            ]
                        )
                        SeparatorView()
                        EnumDefinitionView(
                            name: "MTLFunctionType",
                            availability: "iOS 8.0+",
                            conformances: ["UInt", "@unchecked Sendable"],
                            cases: [
                                EnumCaseView(name: "vertex", value: "1"),
                                EnumCaseView(name: "fragment", value: "2"),
                                EnumCaseView(name: "kernel", value: "3"),
                                EnumCaseView(name: "visible", value: "5" , availability: "iOS 14.0+"),
                                EnumCaseView(name: "intersection", value: "6", availability: "iOS 14.0+"),
                                EnumCaseView(name: "mesh", value: "7", availability: "iOS 16.0+"),
                                EnumCaseView(name: "object", value: "8", availability: "iOS 16.0+")
                            ]
                        )
                        SeparatorView()
                        EnumDefinitionView(
                            name: "MTLLanguageVersion",
                            availability: "iOS 9.0+",
                            conformances: ["UInt", "@unchecked Sendable"],
                            cases: [
                                EnumCaseView(name: "version1_0", value: "65536", availability: "iOS 9.0+", deprecated: "16.0: Use newer standard"),
                                EnumCaseView(name: "version1_1", value: "65537", availability: "iOS 9.0+"),
                                EnumCaseView(name: "version1_2", value: "65538", availability: "iOS 10.0+"),
                                EnumCaseView(name: "version2_0", value: "131072", availability: "iOS 11.0+"),
                                EnumCaseView(name: "version2_1", value: "131073", availability: "iOS 12.0+"),
                                EnumCaseView(name: "version2_2", value: "131074", availability: "iOS 13.0+"),
                                EnumCaseView(name: "version2_3", value: "131075", availability: "iOS 14.0+"),
                                EnumCaseView(name: "version2_4", value: "131076", availability: "iOS 15.0+"),
                                EnumCaseView(name: "version3_0", value: "196608", availability: "iOS 16.0+"),
                                EnumCaseView(name: "version3_1", value: "196609", availability: "iOS 17.0+"),
                                EnumCaseView(name: "version3_2", value: "196610", availability: "iOS 18.0+")
                            ]
                        )
                        SeparatorView()
                        // ... Add other Enums: MTLLibraryType, MTLLibraryOptimizationLevel, etc. ...
                         EnumDefinitionView(
                             name: "MTLLibraryType",
                             availability: "iOS 14.0+",
                             conformances: ["Int", "@unchecked Sendable"],
                             cases: [
                                 EnumCaseView(name: "executable", value: "0"),
                                 EnumCaseView(name: "dynamic", value: "1")
                             ]
                         )
                         SeparatorView()
                         EnumDefinitionView(
                             name: "MTLLibraryOptimizationLevel",
                             availability: "iOS 16.0+",
                             conformances: ["Int", "@unchecked Sendable"],
                             cases: [
                                 EnumCaseView(name: "default", value: "0"),
                                 EnumCaseView(name: "size", value: "1")
                             ]
                         )
                         SeparatorView()
                         EnumDefinitionView(
                             name: "MTLCompileSymbolVisibility",
                             availability: "iOS 16.4+",
                             conformances: ["Int", "@unchecked Sendable"],
                             cases: [
                                 EnumCaseView(name: "default", value: "0"),
                                 EnumCaseView(name: "hidden", value: "1")
                             ]
                         )
                         SeparatorView()
                         EnumDefinitionView(
                             name: "MTLMathMode",
                             availability: "iOS 18.0+ (via usage)",
                             conformances: ["Int", "@unchecked Sendable"],
                             cases: [
                                 EnumCaseView(name: "safe", value: "0"),
                                 EnumCaseView(name: "relaxed", value: "1"),
                                 EnumCaseView(name: "fast", value: "2")
                           ]
                         )
                         SeparatorView()
                          EnumDefinitionView(
                              name: "MTLMathFloatingPointFunctions",
                              availability: "iOS 18.0+ (via usage)",
                              conformances: ["Int", "@unchecked Sendable"],
                              cases: [
                                  EnumCaseView(name: "fast", value: "0"),
                                  EnumCaseView(name: "precise", value: "1")
                            ]
                          )
                    }
                 }

                // MARK: - Classes
                 GroupBox("Classes") {
                    VStack(alignment: .leading, spacing: 10) {
                       ClassDefinitionView(
                           name: "MTLVertexAttribute",
                           availability: "iOS 8.0+",
                           inheritance: ["NSObject"],
                           properties: [
                               PropertyView(name: "name", type: "String { get }"),
                               PropertyView(name: "attributeIndex", type: "Int { get }"),
                               PropertyView(name: "attributeType", type: "MTLDataType { get }", availability: "iOS 8.3+"),
                               PropertyView(name: "isActive", type: "Bool { get }"),
                               PropertyView(name: "isPatchData", type: "Bool { get }", availability: "iOS 10.0+"),
                               PropertyView(name: "isPatchControlPointData", type: "Bool { get }", availability: "iOS 10.0+")
                           ],
                           methods: []
                       )
                       SeparatorView()
                       ClassDefinitionView(
                           name: "MTLAttribute",
                           availability: "iOS 10.0+",
                           inheritance: ["NSObject"],
                           properties: [
                               PropertyView(name: "name", type: "String { get }"),
                               PropertyView(name: "attributeIndex", type: "Int { get }"),
                               PropertyView(name: "attributeType", type: "MTLDataType { get }"),
                               PropertyView(name: "isActive", type: "Bool { get }"),
                               PropertyView(name: "isPatchData", type: "Bool { get }", availability: "iOS 10.0+"),
                               PropertyView(name: "isPatchControlPointData", type: "Bool { get }", availability: "iOS 10.0+")
                           ],
                           methods: []
                       )
                       SeparatorView()
                       ClassDefinitionView(
                           name: "MTLFunctionConstant",
                           availability: "iOS 10.0+",
                           inheritance: ["NSObject"],
                           properties: [
                               PropertyView(name: "name", type: "String { get }"),
                               PropertyView(name: "type", type: "MTLDataType { get }"),
                               PropertyView(name: "index", type: "Int { get }"),
                               PropertyView(name: "required", type: "Bool { get }")
                           ],
                           methods: []
                       )
                       SeparatorView()
                       ClassDefinitionView(
                            name: "MTLCompileOptions",
                            availability: "iOS 8.0+",
                            inheritance: ["NSObject", "NSCopying"],
                            properties: [
                                PropertyView(name: "preprocessorMacros", type: "[String : NSObject]? { get set }"),
                                PropertyView(name: "fastMathEnabled", type: "Bool { get set }", availability: "iOS 8.0+", deprecated: "18.0: Use mathMode"),
                                PropertyView(name: "mathMode", type: "MTLMathMode { get set }", availability: "iOS 18.0+"),
                                PropertyView(name: "mathFloatingPointFunctions", type: "MTLMathFloatingPointFunctions { get set }", availability: "iOS 18.0+"),
                                PropertyView(name: "languageVersion", type: "MTLLanguageVersion { get set }", availability: "iOS 9.0+"),
                                PropertyView(name: "libraryType", type: "MTLLibraryType { get set }", availability: "iOS 14.0+"),
                                PropertyView(name: "installName", type: "String? { get set }", availability: "iOS 14.0+"),
                                PropertyView(name: "libraries", type: "[any MTLDynamicLibrary]? { get set }", availability: "iOS 14.0+"),
                                PropertyView(name: "preserveInvariance", type: "Bool { get set }", availability: "iOS 14.0+"),
                                PropertyView(name: "optimizationLevel", type: "MTLLibraryOptimizationLevel { get set }", availability: "iOS 16.0+"),
                                PropertyView(name: "compileSymbolVisibility", type: "MTLCompileSymbolVisibility { get set }", availability: "iOS 16.4+"),
                                PropertyView(name: "allowReferencingUndefinedSymbols", type: "Bool { get set }", availability: "iOS 16.4+"),
                                PropertyView(name: "maxTotalThreadsPerThreadgroup", type: "Int { get set }", availability: "iOS 16.4+"),
                                PropertyView(name: "enableLogging", type: "Bool { get set }", availability: "iOS 18.0+")
                            ],
                            methods: [] // No methods specifically listed in snippet
                       )
                   }
                 }

                 // MARK: - Protocols
                 GroupBox("Protocols") {
                    VStack(alignment: .leading, spacing: 10) {
                        ProtocolDefinitionView(
                            name: "MTLFunction",
                            availability: "iOS 8.0+",
                            inheritance: ["NSObjectProtocol"],
                            properties: [
                                PropertyView(name: "label", type: "String? { get set }", availability: "iOS 10.0+"),
                                PropertyView(name: "device", type: "any MTLDevice { get }"),
                                PropertyView(name: "functionType", type: "MTLFunctionType { get }"),
                                PropertyView(name: "patchType", type: "MTLPatchType { get }", availability: "iOS 10.0+"),
                                PropertyView(name: "patchControlPointCount", type: "Int { get }", availability: "iOS 10.0+"),
                                PropertyView(name: "vertexAttributes", type: "[MTLVertexAttribute]? { get }"),
                                PropertyView(name: "stageInputAttributes", type: "[MTLAttribute]? { get }", availability: "iOS 10.0+"),
                                PropertyView(name: "name", type: "String { get }"),
                                PropertyView(name: "functionConstantsDictionary", type: "[String : MTLFunctionConstant] { get }", availability: "iOS 10.0+"),
                                PropertyView(name: "options", type: "MTLFunctionOptions { get }", availability: "iOS 14.0+")
                            ],
                            methods: [
                                // Group similar methods if desired
                                MethodView(signature: "makeArgumentEncoder(bufferIndex: Int) -> any MTLArgumentEncoder", availability: "iOS 11.0+"),
                                MethodView(signature: "makeArgumentEncoder(bufferIndex: Int, reflection: AutoreleasingUnsafeMutablePointer<...>?) -> any MTLArgumentEncoder", availability: "iOS 11.0+", deprecated: "16.0: Use MTLDevice's newArgumentEncoderWithBufferBinding:")
                            ]
                        )
                        SeparatorView()
                        ProtocolDefinitionView(
                             name: "MTLLibrary",
                             availability: "iOS 8.0+",
                             inheritance: ["NSObjectProtocol"],
                             properties: [
                                 PropertyView(name: "label", type: "String? { get set }"),
                                 PropertyView(name: "device", type: "any MTLDevice { get }"),
                                 PropertyView(name: "functionNames", type: "[String] { get }"),
                                 PropertyView(name: "type", type: "MTLLibraryType { get }", availability: "iOS 14.0+"),
                                 PropertyView(name: "installName", type: "String? { get }", availability: "iOS 14.0+")
                             ],
                             methods: [
                                 MethodView(signature: "makeFunction(name: String) -> (any MTLFunction)?"),
                                 MethodView(signature: "makeFunction(name: String, constantValues: MTLFunctionConstantValues) throws -> any MTLFunction", availability: "iOS 10.0+"),
                                 MethodView(signature: "makeFunction(name: String, constantValues: ..., completionHandler: @escaping ((any MTLFunction)?, Error?) -> Void)", availability: "iOS 10.0+"),
                                 MethodView(signature: "makeFunction(name: String, constantValues: ...) async throws -> any MTLFunction", availability: "iOS 10.0+"),
                                 MethodView(signature: "makeFunction(descriptor: MTLFunctionDescriptor, completionHandler: @escaping (...))", availability: "iOS 14.0+"),
                                 MethodView(signature: "makeFunction(descriptor: MTLFunctionDescriptor) async throws -> any MTLFunction", availability: "iOS 14.0+"),
                                 MethodView(signature: "makeFunction(descriptor: MTLFunctionDescriptor) throws -> any MTLFunction", availability: "iOS 14.0+"),
                                 MethodView(signature: "makeIntersectionFunction(descriptor: ..., completionHandler: @escaping (...))", availability: "iOS 14.0+"),
                                 MethodView(signature: "makeIntersectionFunction(descriptor: ...) async throws -> any MTLFunction", availability: "iOS 14.0+"),
                                 MethodView(signature: "makeIntersectionFunction(descriptor: ...) throws -> any MTLFunction", availability: "iOS 14.0+")
                             ]
                        )
                    } // VStack
                 } // GroupBox

                 // MARK: - Error Handling
                 GroupBox("Error Handling") {
                     VStack(alignment: .leading, spacing: 10) {
                         Text("Domain Constant:").bold()
                         Text("MTLLibraryErrorDomain: String").padding(.leading)
                             .font(.system(.body, design: .monospaced))

                         SeparatorView()

                         StructDefinitionView(
                             name: "MTLLibraryError",
                             availability: "iOS 8.0+",
                             conformances: ["CustomNSError", "Hashable", "Error"],
                             properties: [
                                 // Implied properties from protocols
                                 PropertyView(name: "errorCode", type: "Int { get } (via CustomNSError)"),
                                 PropertyView(name: "errorUserInfo", type: "[String : Any] { get } (via CustomNSError)"),
                                 PropertyView(name: "localizedDescription", type:"String { get } (via Error)")
                             ],
                             methods: [
                                 MethodView(signature: "init(_nsError: NSError)")
                             ],
                             nestedTypes: [
                                 AnyView( // Use AnyView for type erasure
                                     EnumDefinitionView(
                                         name: "Code",
                                         availability: "iOS 8.0+",
                                         conformances: ["UInt", "@unchecked Sendable", "Equatable"],
                                         cases: [
                                             EnumCaseView(name: "unsupported", value: "1"),
                                             EnumCaseView(name: "internal", value: "2"),
                                             EnumCaseView(name: "compileFailure", value: "3"),
                                             EnumCaseView(name: "compileWarning", value: "4"),
                                             EnumCaseView(name: "functionNotFound", value: "5", availability: "iOS 10.0+"),
                                             EnumCaseView(name: "fileNotFound", value: "6", availability: "iOS 10.0+")
                                         ]
                                     )
                                     .padding(.leading) // Indent nested type
                                     .overlay( // Add visual indicator for nesting
                                         Rectangle().frame(width: 1).foregroundColor(.gray.opacity(0.5)),
                                         alignment: .leading
                                     )
                                 )
                             ]
                         ) // StructDefinitionView
                     } // VStack
                 } // GroupBox

            } // Main VStack
            .padding()
        } // ScrollView
    } // body
}

// MARK: - Helper Views for Structure

struct SeparatorView: View {
    var body: some View {
        Divider().padding(.vertical, 5)
    }
}

// Generic view for displaying Enum definitions consistently
struct EnumDefinitionView: View {
    let name: String
    let availability: String?
    let conformances: [String]?
    let cases: [EnumCaseView]

    var body: some View {
        VStack(alignment: .leading) {
            Text("enum \(name)").font(.title3)
            if let availability = availability {
                Text(availability).font(.caption).foregroundColor(.gray)
            }
            if let conformances = conformances, !conformances.isEmpty {
                Text("Conforms: \(conformances.joined(separator: ", "))")
                    .font(.caption).italic().foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                ForEach(cases.indices, id: \.self) { index in
                    cases[index]
                }
            }
            .padding(.top, 2)
        }
    }
}

// Generic view for Class definitions
struct ClassDefinitionView: View {
    let name: String
    let availability: String?
    let inheritance: [String]?
    let properties: [PropertyView]
    let methods: [MethodView]

    var body: some View {
        VStack(alignment: .leading) {
            Text("open class \(name)").font(.title3)
             if let availability = availability {
                 Text(availability).font(.caption).foregroundColor(.gray)
             }
             if let inheritance = inheritance, !inheritance.isEmpty {
                 Text("Inherits: \(inheritance.joined(separator: ", "))")
                     .font(.caption).italic().foregroundColor(.gray)
             }
             // Properties Section
             if !properties.isEmpty {
                 Text("Properties").font(.headline).padding(.top, 5)
                 VStack(alignment: .leading) {
                     ForEach(properties.indices, id: \.self) { index in
                         properties[index]
                     }
                 }
             }
             // Methods Section (Optional)
             if !methods.isEmpty {
                 Text("Methods").font(.headline).padding(.top, 5)
                 VStack(alignment: .leading) {
                     ForEach(methods.indices, id: \.self) { index in
                         methods[index]
                     }
                 }
             }

        }
    }
}

// Generic view for Protocol definitions
struct ProtocolDefinitionView: View {
     let name: String
     let availability: String?
     let inheritance: [String]?
     let properties: [PropertyView]
     let methods: [MethodView]

     var body: some View {
         VStack(alignment: .leading) {
             Text("protocol \(name)").font(.title3)
             if let availability = availability {
                 Text(availability).font(.caption).foregroundColor(.gray)
             }
             if let inheritance = inheritance, !inheritance.isEmpty {
                 Text("Inherits: \(inheritance.joined(separator: ", "))")
                     .font(.caption).italic().foregroundColor(.gray)
             }
             // Properties Section
             if !properties.isEmpty {
                 Text("Properties").font(.headline).padding(.top, 5)
                 VStack(alignment: .leading) {
                     ForEach(properties.indices, id: \.self) { index in
                         properties[index]
                     }
                 }
             }
             // Methods Section
             if !methods.isEmpty {
                 Text("Methods").font(.headline).padding(.top, 5)
                 VStack(alignment: .leading) {
                     ForEach(methods.indices, id: \.self) { index in
                         methods[index]
                     }
                 }
             }
         }
     }
}

// Generic view for Struct definitions
struct StructDefinitionView: View {
     let name: String
     let availability: String?
     let conformances: [String]?
     let properties: [PropertyView]
     let methods: [MethodView]
     let nestedTypes: [AnyView]? // Allow embedding other definitions

     var body: some View {
         VStack(alignment: .leading) {
             Text("struct \(name)").font(.title3)
             if let availability = availability {
                 Text(availability).font(.caption).foregroundColor(.gray)
             }
             if let conformances = conformances, !conformances.isEmpty {
                 Text("Conforms: \(conformances.joined(separator: ", "))")
                     .font(.caption).italic().foregroundColor(.gray)
             }
              // Properties Section
              if !properties.isEmpty {
                  Text("Properties").font(.headline).padding(.top, 5)
                  VStack(alignment: .leading) {
                      ForEach(properties.indices, id: \.self) { index in
                          properties[index]
                      }
                  }
              }
             // Methods Section
             if !methods.isEmpty {
                 Text("Methods").font(.headline).padding(.top, 5)
                 VStack(alignment: .leading) {
                     ForEach(methods.indices, id: \.self) { index in
                         methods[index]
                     }
                 }
             }
             // Nested Types Section
             if let nestedTypes = nestedTypes, !nestedTypes.isEmpty {
                  Text("Nested Types").font(.headline).padding(.top, 5)
                  VStack(alignment: .leading) {
                      ForEach(nestedTypes.indices, id: \.self) { index in
                         nestedTypes[index]
                      }
                  }
             }
         }
     }
}

// MARK: - Preview

#Preview {
    MetalDocsSwiftUIView()
}
