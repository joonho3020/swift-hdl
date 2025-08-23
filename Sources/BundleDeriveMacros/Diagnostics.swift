import SwiftDiagnostics
import SwiftSyntax

enum BundleDiag {
  struct ContainsSelf: DiagnosticMessage {
    let propertyName: String
    let typeName: String
    var message: String { "Bundle cannot contain itself: property ‘\(propertyName)’ has type ‘\(typeName)’" }
    var diagnosticID: MessageID { .init(domain: "BundleDerive", id: "contains-self") }
    var severity: DiagnosticSeverity { .error }
  }

  struct NotStruct: DiagnosticMessage {
    var message: String { "@BundleDerive can only be applied to a struct" }
    var diagnosticID: MessageID { .init(domain: "BundleDerive", id: "not-struct") }
    var severity: DiagnosticSeverity { .error }
  }
}