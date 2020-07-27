import UIKit

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    static var primaryRed: UIColor = {
        return UIColor(hexString: "#FF005C")
    }()
    
    static var primaryGreen: UIColor = {
        return UIColor(hexString: "#03BDA7")
    }()
    
    static var backgroundPink: UIColor = {
        return UIColor(hexString: "#FFBEC6")
    }()
    
    static var backgroundYellow: UIColor = {
        return UIColor(hexString: "#FFF2D4")
    }()
    
    static var backgroundLightGray: UIColor = {
        return UIColor(hexString: "#F3F3F3")
    }()
    
    static var textGray: UIColor = {
        return UIColor(hexString: "#666666")
    }()
    
    static var textBlack: UIColor = {
        return UIColor(hexString: "#040404")
    }()
    
    static var otherNavy: UIColor = {
        return UIColor(hexString: "#2F2E41")
    }()
    
    static var otherRed: UIColor = {
        return UIColor(hexString: "#FF5364")
    }()
}
