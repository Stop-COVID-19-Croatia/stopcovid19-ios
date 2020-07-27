import Foundation

struct TestResult: Codable {
    var id: UUID
    var isAdded: Bool
    var dateAdministered: Date
    var isShared: Bool         
}
