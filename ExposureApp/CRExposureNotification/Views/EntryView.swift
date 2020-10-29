import UIKit

class EntryStackView: UIStackView {
    var activate: (() -> Void)?
    override func accessibilityActivate() -> Bool {
        activate?()
        return true
    }
}

class EntryView: UIView, UITextFieldDelegate {
    
    let numberOfDigits = 6
    
    var textFields = [UITextField]()
    var stackView: EntryStackView?
    
    var text: String {
        textFields.map { $0.text ?? "" }.joined()
    }
    
    var textDidChange: (() -> Void)?
    
    func combinedAccessibilityTextFieldValues() -> String {
        var string = ""
        for textField in textFields {
            string += textField.accessibilityValue ?? ""
        }
        return string
    }
 
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        
        let label = UILabel()
        label.text = NSLocalizedString("VERIFICATION_IDENTIFIER_ENTRY_LABEL", comment: "Label")
        label.font = .preferredFont(forTextStyle: .callout)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        
        for _ in 0..<numberOfDigits {
            let textField = UITextField()
            textField.adjustsFontForContentSizeCategory = true
            textField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.borderStyle = .none
            textField.backgroundColor = .tertiarySystemBackground
            textField.layer.cornerRadius = 8.0
            textField.layer.cornerCurve = .continuous
            textField.delegate = self
            textField.isAccessibilityElement = false
            textFields.append(textField)
        }
        
        let entryStackView = UIStackView(arrangedSubviews: textFields)
        entryStackView.axis = .horizontal
        entryStackView.distribution = .fillEqually
        entryStackView.spacing = 8.0
        
        let stackView = EntryStackView(arrangedSubviews: [label, entryStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.accessibilityLabel = label.accessibilityLabel
        if let firstTextField = textFields.first {
            stackView.accessibilityTraits = firstTextField.accessibilityTraits
        }
        stackView.isAccessibilityElement = true
        
        stackView.activate = { [weak self] in
            self?.textFields.first?.becomeFirstResponder()
        }
        self.stackView = stackView
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            entryStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            entryStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80.0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12.0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        let index = textFields.firstIndex(of: textField)!
        if string.isEmpty {
            if index > 1 {
                textFields[index - 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else {
            if index < numberOfDigits - 1 {
                textFields[index + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        textDidChange?()
        stackView?.accessibilityValue = combinedAccessibilityTextFieldValues()
        return false
    }
}
