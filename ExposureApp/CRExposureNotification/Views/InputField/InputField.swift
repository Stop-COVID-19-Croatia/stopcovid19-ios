import UIKit

protocol InputFieldDelegate {
   func didChangeTextFieldVaule(isMaxLenghtReached: Bool)
}

class InputField: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    private var maxLength = 150
    public var delegate: InputFieldDelegate?

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
        
    @IBInspectable var placeholderText: String? {
        get {
            return textField.text
        }
        
        set {
            textField.text = newValue?.localized()
            hintLabel.text = newValue?.localized()
        }
    }
    
    @IBInspectable var maxCharLength: Int {
        get {
            return maxLength
        }
        
        set {
            maxLength = newValue
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
        hintLabel.isHidden = false
        textField.text = nil
        delegate?.didChangeTextFieldVaule(isMaxLenghtReached: false)
        borderColor = .primaryGreen
    }
    
    func deselect() {
        hintLabel.isHidden = true
        textField.text = (textField.text != nil && !textField.text!.isEmpty) ? textField.text : hintLabel.text
        borderColor = .backgroundLightGray
    }
}

extension InputField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        delegate?.didChangeTextFieldVaule(isMaxLenghtReached: !(newString.length < maxLength))
        return newString.length <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setSelected()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        deselect()
    }
}
