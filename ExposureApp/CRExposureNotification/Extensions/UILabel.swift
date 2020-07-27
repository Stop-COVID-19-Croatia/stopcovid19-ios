import UIKit

extension UILabel {
    
    @IBInspectable var localizabelString : String {
        
        set{
            self.text = newValue.localized()
        }
        
        get{
            return self.text ?? ""
        }
    }
    
    func formatHtml(){
        let modifiedFont = String(format:"<div style=\"text-align: \(textAlignment.descripton);\"> <span style=\"font-family: '-apple-system', '\(self.font.fontName)'; font-size: \(self.font!.pointSize)\">%@</span> </div>", self.text ?? Constants.emptyStringPreview)
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        self.attributedText = attrStr
    }
    
    func underline() {
        if let textString = text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(   NSAttributedString.Key.underlineStyle,
                                             value: NSUnderlineStyle.single.rawValue,
                                             range: NSRange(location: 0,
                                                            length: attributedString.length))
            attributedText = attributedString
        }
    }
}

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

