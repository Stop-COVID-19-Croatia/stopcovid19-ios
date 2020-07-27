import UIKit

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            let mutableAttributed = NSMutableAttributedString()
            mutableAttributed.append(try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil))
            return mutableAttributed
        } catch {
            return NSAttributedString()
        }
    }
    
}
