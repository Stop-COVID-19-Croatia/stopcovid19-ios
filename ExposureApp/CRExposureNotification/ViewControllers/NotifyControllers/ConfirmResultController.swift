import UIKit

class ConfirmResultController: BaseController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeInputField: InputField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var dateInputField: InputField!
    
    private var selectedDate: Date?
    
    private var didShareKeys: (() -> Void)?
    static func instantiate(didShareKeys: @escaping () -> Void) -> ConfirmResultController {
        let controller = UIUtil.controllerFromStoryboard(storyboard: .notify, controller: .confirmResultController) as! ConfirmResultController
        controller.didShareKeys = didShareKeys
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeInputField.delegate = self
        hideKeyboardWhenTappedAround()
        addObserverForKeyboard()
    }
    
    @IBAction func close() {
        dismissKeyboard()
        dismiss(animated: true)
    }
    
    @IBAction func pickDate() {
        dismissKeyboard()
        dateInputField.setSelected()
        DatePickerController.shared.present(in: self, title: "ConfirmResultController.DatePickerTitle".localized(), preselectedDate: selectedDate, maximumDate: Date()) { pickedDate in
            DispatchQueue.main.async {
                self.selectedDate = pickedDate
                self.dateInputField.textField.text = pickedDate.stringDMYFormat()
                self.dateInputField.deselect()
            }
        }
    }
    
    @IBAction func confirm() {
        dismissKeyboard()
        if !ExposureManager.shared.manager.exposureNotificationEnabled {
            self.view.window?.windowScene?.open(URL(string: UIApplication.openSettingsURLString)!, options: nil, completionHandler: nil)
            return
        }
        ExposureManager.getTemporaryExposureKeys { (keys, error) in
            if error != nil {
                if !(error!.errorMessage?.contains("4.") ?? false){
                    ErrorHandler.handle(error: error!, in: self)
                }
                return
            }
            self.startLoader()
            ExposuresProvider.postDiagnosisKeys(DiagnosisKeyInput(temporaryExposureKeys: keys), authValue: self.codeInputField.textField.text, success: { (response) in
                DispatchQueue.main.async {
                    self.stopLoader()
                    if var dates = (Storage.readObject(key: StorageKeys.sharedKeys) as? [Date]) {
                        dates.append(Date())
                        Storage.save(dates, key: StorageKeys.sharedKeys, override: true)
                    } else {
                        Storage.save([Date()], key: StorageKeys.sharedKeys, override: true)
                    }
                    self.didShareKeys?()
                    UIUtil.showInfoAlertWithHandler(viewController: self,title: "", messageText: "ConfirmResultController.ThankYouForSharingYourTestResult".localized()) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.stopLoader()
                    ErrorHandler.handle(error: error, in: self)
                }
            }
        }
    }
    
    deinit {
        print("DEINIT ConfirmResultController")
        removeObserverForKeyboard()
    }
}

extension ConfirmResultController: InputFieldDelegate {
    func didChangeTextFieldVaule(isMaxLenghtReached: Bool) {
        if isMaxLenghtReached {
            btnNext.isEnabled = true
            btnNext.alpha = 1
        } else {
            btnNext.isEnabled = false
            btnNext.alpha = 0.5
        }
    }
}

extension ConfirmResultController {
    override func keyboardWasShown(notification: Notification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    override func keyboardWillBeHidden(notification: Notification) {
        scrollView.contentInset.bottom = .zero
    }
}
