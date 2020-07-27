import UIKit

class ShadowViewContainer: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var shadowRadius: CGFloat = 2.5
    @IBInspectable var shadowOpacity: Float = 0.2
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
