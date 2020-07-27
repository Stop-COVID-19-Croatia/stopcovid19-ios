import Foundation

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".")[1]
    }
}
