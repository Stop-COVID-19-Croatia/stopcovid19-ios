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
    
    func partTextModifier(fullText: String, changeText: String, color: UIColor = .black, font: UIFont = .systemFont(ofSize: 14)) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText, options: .backwards)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: font , range: range)

        self.attributedText = attribute
        self.setNeedsDisplay()
        self.layoutIfNeeded()
    }
}

