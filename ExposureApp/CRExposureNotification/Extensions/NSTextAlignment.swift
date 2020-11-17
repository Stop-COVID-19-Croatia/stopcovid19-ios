import UIKit

extension NSTextAlignment {
    var descripton: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        case .justified:
            return "justified"
        case .natural:
            return "natural"
        @unknown default:
            return "left"
        }
    }
}
