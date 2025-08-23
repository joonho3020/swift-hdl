import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct BundleDerivePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [BundleDerive.self]
}

public struct BundleDerive: MemberMacro {
    // Insert members into the annotated type (e.g., fast bitWidth)
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let s = decl.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(decl), message: BundleDiag.NotStruct()))
            return []
        }

        let typeName = s.name.text
        let fields = collectStoredProperties(from: s, typeName: typeName)

        // Synthesize `var bitWidth: Int { f1.bitWidth + f2.bitWidth + ... }`
        let sumExpr = fields.isEmpty ? "0" : fields.map { "self.\($0).bitWidth" }.joined(separator: " + ")
        let bitWidthDecl: DeclSyntax = """
        public var bitWidth: Int { \(raw: sumExpr) }
        """

        return [bitWidthDecl]
    }

    // TODO: extension for elementwise operations?
    // extension Wire where T == MyBundle {
    //     public static func + (lhs: Wire, rhs: Wire) -> Wire {
    //         Wire(MyBundle(
    //           x: (lhs.x + rhs.x).value,
    //           y: (lhs.y + rhs.y).value
    //         ), name: "add(\(lhs.name),\(rhs.name))")
    //     }
    //     // same for -, &, |, etc.
    // }
}

private func collectStoredProperties(from s: StructDeclSyntax, typeName _: String) -> [String] {
    var fields: [String] = []

    for member in s.memberBlock.members {
        guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

        for binding in varDecl.bindings {
            // Skip computed properties
            if binding.accessorBlock != nil { continue }
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }

            let name = pattern.identifier.text
            fields.append(name)
        }
    }
    return fields
}
