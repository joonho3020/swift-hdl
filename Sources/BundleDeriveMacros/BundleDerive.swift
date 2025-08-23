import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct BundleDerivePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [BundleDerive.self]
}

public struct BundleDerive: MemberMacro, ExtensionMacro {
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

    let typeName = s.name.text
    let (fields, diags) = collectStoredProperties(from: s, typeName: typeName)
    diags.forEach { context.diagnose($0) }

    // Synthesize `var bitWidth: Int { f1.bitWidth + f2.bitWidth + ... }`
    let sumExpr = fields.isEmpty ? "0" : fields.map { "self.\($0.name).bitWidth" }.joined(separator: " + ")
    let bitWidthDecl: DeclSyntax = """
    public var bitWidth: Int { \(raw: sumExpr) }
    """

    // public init(hdr: Header, payload: HWUInt) { self.hdr = hdr; self.payload = payload }
    let initArgsExpr   = fields.isEmpty ? "" : fields.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
    let assignArgsExpr = fields.isEmpty ? "" : fields.map { "self.\($0.name) = \($0.name)" }.joined(separator: "; ")
    let initDecl: DeclSyntax = """
    public init(\(raw: initArgsExpr)) { \(raw: assignArgsExpr) }
    """

    return [bitWidthDecl, initDecl]
  }

  // FIXME: This macro creates a new Wire every time you access a Bundle subfield.
  // What we really want is to return a handle to the subfield of the already created Wire node
  // However, this is nice in that the subfield access returns a typed instance
  //
  // extension Wire where T == MyBundle {
  //   public var field: Wire<F> {
  //     Wire<F>(self.value.field, name: self.name.isEmpty ? "field" : "\(self.name).field")
  //   }
  // }
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo decl: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let s = decl.as(StructDeclSyntax.self) else {
      context.diagnose(Diagnostic(node: Syntax(decl), message: BundleDiag.NotStruct()))
      return []
    }

    let typeName = s.name.text
    let typeWithGenerics = typeName + genericArgumentList(from: s)

    let (fields, diags) = collectStoredProperties(from: s, typeName: typeName)
    diags.forEach { context.diagnose($0) }

    // Build properties: one computed property per stored field.
    let accessors: [DeclSyntax] = fields.map { field in
      let fname = field.name
      let ftype = field.type
      return """
      public var \(raw: fname): Wire<\(raw: ftype)> {
        assert(self._id != nil)
        Wire<\(raw: ftype)>(self.value.\(raw: fname)", self._id!)
      }
      """
    }

    let ext = try ExtensionDeclSyntax("""
    extension Wire where T == \(raw: typeWithGenerics) \(raw: genericWhereClause(from: s)) {
      \(raw: accessors.map { $0.description }.joined(separator: "\n"))
    }
    """)

    return [ext]
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
  guard let params = s.genericParameterClause?.parameters else { return "" }
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
