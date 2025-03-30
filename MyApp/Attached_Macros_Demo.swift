//
//  Attached_Macros_Demo.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import Foundation // Import Foundation for basic types if needed

// MARK: - Conceptual Macro Infrastructure (Placeholder Protocols)
// These protocols mimic the real ones for illustration purposes.
// In a real macro project, you'd import SwiftSyntax and conform to
// protocols like PeerMacro, MemberMacro, AccessorMacro, etc.

// Base protocol for all macros (as in SE-0382)
protocol Macro {}

// Base protocol for attached macros
protocol AttachedMacro: Macro {}

// --- Role Protocols (Conceptual) ---

// Represents the context passed to expansion functions
protocol MacroExpansionContext {
    func createUniqueName(_ name: String) -> String // For generating unique identifiers
    // ... other potential utilities
}

// Mimics the type for syntax nodes (attribute, declarations)
protocol SyntaxNode {
    // In reality, these would be specific types like
    // AttributeSyntax, DeclSyntaxProtocol, etc. from SwiftSyntax
    var description: String { get } // Simplified representation
}
struct PlaceholderSyntaxNode: SyntaxNode { let description: String }
struct PlaceholderAttributeSyntax: SyntaxNode { let description: String }
struct PlaceholderDeclGroupSyntax: SyntaxNode { let description: String } // For types/extensions
struct PlaceholderDeclSyntax: SyntaxNode { let description: String } // For any declaration
struct PlaceholderAccessorDeclSyntax: SyntaxNode { let description: String } // For accessors
struct PlaceholderTypeSyntax: SyntaxNode { let description: String } // For types in conformances
struct PlaceholderWhereClauseSyntax: SyntaxNode { let description: String } // For where clauses

// Peer Macro Role Protocol (Conceptual)
protocol PeerMacro: AttachedMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax, // The @Macro attribute
        providingPeersOf declaration: PlaceholderDeclSyntax, // The declaration it's attached to
        in context: MacroExpansionContext
    ) throws -> [PlaceholderDeclSyntax] // Returns new declarations alongside
}

// Member Macro Role Protocol (Conceptual)
protocol MemberMacro: AttachedMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingMembersOf declaration: PlaceholderDeclGroupSyntax, // The type/extension
        in context: MacroExpansionContext
    ) throws -> [PlaceholderDeclSyntax] // Returns new members
}

// Accessor Macro Role Protocol (Conceptual)
protocol AccessorMacro: AttachedMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingAccessorsOf declaration: PlaceholderDeclSyntax, // The property/subscript
        in context: MacroExpansionContext
    ) throws -> [PlaceholderAccessorDeclSyntax] // Returns accessors (get/set)
}

// Member Attribute Macro Role Protocol (Conceptual)
protocol MemberAttributeMacro: AttachedMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        attachedTo declaration: PlaceholderDeclGroupSyntax, // The type/extension
        providingAttributesFor member: PlaceholderDeclSyntax, // The existing member
        in context: MacroExpansionContext
    ) throws -> [PlaceholderAttributeSyntax] // Returns attributes to add to member
}

// Conformance Macro Role Protocol (Conceptual)
protocol ConformanceMacro: AttachedMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingConformancesOf declaration: PlaceholderDeclGroupSyntax, // The type
        in context: MacroExpansionContext
    ) throws -> [(PlaceholderTypeSyntax, PlaceholderWhereClauseSyntax?)] // Returns (Protocol, WhereClause?) pairs
}

// Dummy context for illustration
struct DummyContext: MacroExpansionContext {
    func createUniqueName(_ name: String) -> String {
        return "__\(name)_\(UUID().uuidString.prefix(4))"
    }
}

enum MacroError: Error {
    case message(String)
}

// MARK: - Example Macro Definitions

// 1. Peer Macro: AddCompletionHandler (Simplified from proposal)
//    - Role: Peer Macro
//    - Naming: `overloaded` (same base name as attached function)
@attached(peer, names: overloaded) // Define role and name kind
macro AddCompletionHandler() = #externalMacro(module: "ExampleMacros", type: "AddCompletionHandlerMacro")
// Note: `#externalMacro` links definition to implementation type.

// 2. Member Macro: AddCaseIterableDefaults
//    - Role: Member Macro
//    - Naming: `named(allCases)` (knows it adds 'allCases'), `arbitrary` (adds computed vars based on cases)
@attached(member, names: named(allCases), arbitrary)
macro AddCaseIterableDefaults() = #externalMacro(module: "ExampleMacros", type: "AddCaseIterableDefaultsMacro")

// 3. Accessor Macro: ClampingWrapper (Simplified from proposal)
//    - Role: Accessor Macro
//    - Naming: Implicit (doesn't introduce *new top-level visible* names, only accessors)
@attached(accessor)
macro ClampingWrapper(min: Int, max: Int) = #externalMacro(module: "ExampleMacros", type: "ClampingWrapperMacro")

// 4. Member Attribute Macro: AddCodableToMembers
//    - Role: Member Attribute Macro
//    - Naming: Not applicable (modifies existing members, doesn't create new named decls)
@attached(memberAttribute)
macro AddCodableToMembers() = #externalMacro(module: "ExampleMacros", type: "AddCodableToMembersMacro")

// 5. Conformance Macro: AddEquatableConformance
//    - Role: Conformance Macro
@attached(conformance)
macro AddEquatableConformance() = #externalMacro(module: "ExampleMacros", type: "AddEquatableConformanceMacro")

// 6. Composition Macro: SynthesizeCodableEquatable
//    - Roles: Member (for CodingKeys), Conformance (for Codable, Equatable)
@attached(member, names: named(CodingKeys)) // Adds CodingKeys enum
@attached(conformance)                     // Adds Codable conformance
@attached(conformance)                     // Adds Equatable conformance (conceptually distinct expansion call)
macro SynthesizeCodableEquatable() = #externalMacro(module: "ExampleMacros", type: "SynthesizeCodableEquatableMacro")

// MARK: - Example Macro Implementations (Conceptual)

struct AddCompletionHandlerMacro: PeerMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingPeersOf declaration: PlaceholderDeclSyntax,
        in context: MacroExpansionContext
    ) throws -> [PlaceholderDeclSyntax] {
        // ** Conceptual Logic **
        // 1. Validate: Check if 'declaration' is an async function.
        // 2. Parse: Extract function name, parameters, return type.
        // 3. Generate: Create a new non-async function signature with a completion handler param.
        // 4. Generate: Create a body that calls the original async func in a Task and calls the completion handler.
        
        print("Expanding AddCompletionHandler for declaration: \(declaration.description)") // Debug print
        
        // Return a string representing the GENERATED peer function syntax
        let functionName = "originalAsyncFunction" // Assume extracted name
        let returnType = "String?" // Assume extracted
        let generatedCode = """
        func \(functionName)(/* original params..., */ completionHandler: @escaping (\(returnType)) -> Void) {
            Task {
                let result = await \(functionName)(/* original args... */)
                completionHandler(result)
            }
        }
        """
        return [PlaceholderDeclSyntax(description: generatedCode)]
    }
}

struct AddCaseIterableDefaultsMacro: MemberMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingMembersOf declaration: PlaceholderDeclGroupSyntax,
        in context: MacroExpansionContext
    ) throws -> [PlaceholderDeclSyntax] {
        // ** Conceptual Logic **
        // 1. Validate: Check if 'declaration' is an enum.
        // 2. Parse: Find all the cases within the enum.
        // 3. Generate 'allCases': Create `static var allCases: [Self] = [.case1, .case2, ...]`
        // 4. Generate helpers (arbitrary names): Create `static var isCase1: Bool { self == .case1 }`, etc.
        
        print("Expanding AddCaseIterableDefaults for type: \(declaration.description)") // Debug print
        
        let allCasesMember = """
        static var allCases: [Self] {
          return [/* list of all cases */]
        }
        """
        let arbitraryMember = """
        // Computed properties for each case (arbitrary names based on cases)
        var isSomeCase: Bool { /* check self == .someCase */ true }
        """
        return [
            PlaceholderDeclSyntax(description: allCasesMember),
            PlaceholderDeclSyntax(description: arbitraryMember) // Represents multiple arbitrary members
        ]
    }
}

struct ClampingWrapperMacro: AccessorMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingAccessorsOf declaration: PlaceholderDeclSyntax,
        in context: MacroExpansionContext
    ) throws -> [PlaceholderAccessorDeclSyntax] {
        // ** Conceptual Logic **
        // 1. Validate: Check if 'declaration' is a stored property `var name: Type`.
        // 2. Parse: Extract property name, type, and min/max from the '@ClampingWrapper' attribute ('node').
        // 3. Generate `get`: Return the backing store (implicitly assumed or could be generated by a peer).
        // 4. Generate `set`: Check bounds using min/max, then assign clamped value to backing store.
        // 5. Requires a backing store (often generated by a companion Peer macro role if emulating Property Wrappers fully).
        
        print("Expanding ClampingWrapper for property: \(declaration.description) attached to \(node.description)") // Debug print
        
        // NOTE: A full `@propertyWrapper` emulation often *also* uses a Peer macro
        //       to create the `_propertyName` backing store. This example focuses only
        //       on generating the accessors themselves, assuming a store exists.
        
        let minVal = "0" // Extracted from 'node'
        let maxVal = "100" // Extracted from 'node'
        let uniqueNewValue = context.createUniqueName("newValue")
        let getter = """
        get {
            // Assumes backstore exists (e.g., _propertyName)
            return _propertyName // Placeholder for actual backing store access
        }
        """
        let setter = """
        set(\(uniqueNewValue)) {
            // Assumes backstore exists (e.g., _propertyName)
            if \(uniqueNewValue) < \(minVal) {
                _propertyName = \(minVal)
            } else if \(uniqueNewValue) > \(maxVal) {
                _propertyName = \(maxVal)
            } else {
                _propertyName = \(uniqueNewValue)
            }
        }
        """
        return [
            PlaceholderAccessorDeclSyntax(description: getter),
            PlaceholderAccessorDeclSyntax(description: setter)
        ]
    }
}

struct AddCodableToMembersMacro: MemberAttributeMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        attachedTo declaration: PlaceholderDeclGroupSyntax,
        providingAttributesFor member: PlaceholderDeclSyntax,
        in context: MacroExpansionContext
    ) throws -> [PlaceholderAttributeSyntax] {
        // ** Conceptual Logic **
        // 1. Check 'member': If it's a stored property not already marked Codable/non-Codable.
        // 2. Generate: Return `@Codable` attribute syntax.
        
        print("Expanding AddCodableToMembers for member: \(member.description) inside \(declaration.description)")
        
        // Conceptual: only add if it's appropriate (e.g., a stored property)
        let shouldAddAttribute = true // Simplified check
        if shouldAddAttribute {
            return [PlaceholderAttributeSyntax(description: "@Codable")] // Or potentially Encodable/Decodable
        } else {
            return []
        }
    }
}

struct AddEquatableConformanceMacro: ConformanceMacro {
    static func expansion(
        of node: PlaceholderAttributeSyntax,
        providingConformancesOf declaration: PlaceholderDeclGroupSyntax,
        in context: MacroExpansionContext
    ) throws -> [(PlaceholderTypeSyntax, PlaceholderWhereClauseSyntax?)] {
        // ** Conceptual Logic **
        // 1. Generate: Return the `Equatable` type syntax.
        
        print("Expanding AddEquatableConformance for type: \(declaration.description)")
        
        let equatableType = PlaceholderTypeSyntax(description: "Equatable")
        return [(equatableType, nil)] // No where clause in this simple case
    }
}

struct SynthesizeCodableEquatableMacro: MemberMacro, ConformanceMacro {
    // --- Member Role Implementation ---
    static func expansion( // Provides CodingKeys
        of node: PlaceholderAttributeSyntax,
        providingMembersOf declaration: PlaceholderDeclGroupSyntax,
        in context: MacroExpansionContext
    ) throws -> [PlaceholderDeclSyntax] {
        print("Expanding SynthesizeCodableEquatable (Member Role) for type: \(declaration.description)")
        // ** Conceptual Logic **
        // 1. Parse 'declaration': Find all stored properties.
        // 2. Generate 'CodingKeys': Create `enum CodingKeys: String, CodingKey { case prop1, prop2... }`
        let codingKeysEnum = """
        enum CodingKeys: String, CodingKey {
            // case member1
            // case member2
            // ...
        }
        """
        return [PlaceholderDeclSyntax(description: codingKeysEnum)]
    }
    
    // --- Conformance Role Implementation ---
    static func expansion( // Provides Codable and Equatable
        of node: PlaceholderAttributeSyntax,
        providingConformancesOf declaration: PlaceholderDeclGroupSyntax,
        in context: MacroExpansionContext
    ) throws -> [(PlaceholderTypeSyntax, PlaceholderWhereClauseSyntax?)] {
        print("Expanding SynthesizeCodableEquatable (Conformance Role) for type: \(declaration.description)")
        // ** Conceptual Logic **
        // 1. Return `Codable` and `Equatable` conformances.
        // Note: Even though this single function handles multiple `@attached(conformance)`
        // lines in the definition, Swift calls the appropriate *protocol* requirement.
        // A real implementation might need distinct struct conformances if the logic differs significantly,
        // but here we combine for simplicity as the *concept* is adding conformances.
        
        let codableType = PlaceholderTypeSyntax(description: "Codable")
        let equatableType = PlaceholderTypeSyntax(description: "Equatable")
        return [
            (codableType, nil),
            (equatableType, nil)
        ]
    }
}
