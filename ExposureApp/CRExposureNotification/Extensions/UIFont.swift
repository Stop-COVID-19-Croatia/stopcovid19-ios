import UIKit

extension UIFont {
    
    open class func sfCompactRegularBold(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactDisplay-Semibold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    open class func sfCompactRegular(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactText-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

    }
}
