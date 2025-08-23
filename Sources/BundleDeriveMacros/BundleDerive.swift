import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder

@main
struct BundleDerivePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [BundleDerive.self]
}

public struct BundleDerive: MemberMacro {
  // Insert members into the annotated type (e.g., fast bitWidth)
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf decl: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let s = decl.as(StructDeclSyntax.self) else {
      context.diagnose(Diagnostic(node: Syntax(decl), message: BundleDiag.NotStruct()))
      return []
    }

    let typeName = s.identifier.text
    let (fields, diags) = collectStoredProperties(from: s, typeName: typeName)
    diags.forEach { context.diagnose($0) }

    // Synthesize `var bitWidth: Int { f1.bitWidth + f2.bitWidth + ... }`
    let sumExpr = fields.isEmpty ? "0" : fields.map { "self.\($0.name).bitWidth" }.joined(separator: " + ")

    let bitWidthDecl: DeclSyntax = """
    public var bitWidth: Int { \(raw: sumExpr) }
    """

    return [bitWidthDecl]
  }
}

// MARK: - Helpers
private func collectStoredProperties(from s: StructDeclSyntax, typeName: String) -> (fields: [(name: String, type: String)], diags: [Diagnostic]) {
  var fields: [(String, String)] = []
  var diags: [Diagnostic] = []

  for member in s.memberBlock.members {
    guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

    for binding in varDecl.bindings {
      // Skip computed properties
      if binding.accessorBlock != nil { continue }
      guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
      guard let typeAnn = binding.typeAnnotation?.type else { continue }

      let name = pattern.identifier.text
      let tyString = typeAnn.trimmedDescription

      // Self-containment check: Self, Optional<Self>, TypeName, Optional<TypeName>
      if isSelfType(tyString: tyString, typeName: typeName) {
        let msg = BundleDiag.ContainsSelf(propertyName: name, typeName: tyString)
        diags.append(Diagnostic(node: Syntax(binding), message: msg))
      }

      fields.append((name, tyString))
    }
  }
  return (fields, diags)
}

private func isSelfType(tyString: String, typeName: String) -> Bool {
  let t = tyString.replacingOccurrences(of: " ", with: "")
  if t == "Self" || t == typeName { return true }
  if t == "Optional<Self>" || t == "Self?" { return true }
  if t == "Optional<\(typeName)>" || t == "\(typeName)?" { return true }
  return false
}

private func genericArgumentList(from s: StructDeclSyntax) -> String {
  // Rebuild `Foo<A,B>` from the generic parameter clause, if any.
  guard let params = s.genericParameterClause?.genericParameterList else { return "" }
  let names = params.map { $0.name.text }.joined(separator: ", ")
  return names.isEmpty ? "" : "<\(names)>"
}

private func genericWhereClause(from s: StructDeclSyntax) -> String {
  // Preserve where-clause if present on the struct
  if let whereClause = s.genericWhereClause?.description.trimmingCharacters(in: .whitespacesAndNewlines), !whereClause.isEmpty {
    return whereClause
  }
  return ""
}