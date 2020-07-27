import UIKit

class LanguageButton: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: borderView.layer.borderColor ?? UIColor.clear.cgColor)
        }
        
        set {
            borderView.layer.borderColor = newValue?.cgColor ?? UIColor.clear.cgColor
        }
    }
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(borderView.layer.borderWidth)
        }
        
        set {
            borderView.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable var languageImage: UIImage? {
        get {
            return languageImageView.image
        }
        
        set {
            languageImageView.image = newValue
        }
    }
    
    @IBInspectable var languageText: String? {
        get {
            return languageLabel.text
        }
        
        set {
            languageLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed(self.className, owner: self)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        borderWidth = 2
    }
    
    func setSelected() {
        borderColor = .primaryGreen
        borderView.backgroundColor = .white
    }
    
    func deselect() {
        borderColor = .clear
        borderView.backgroundColor = .backgroundLightGray
    }
}
