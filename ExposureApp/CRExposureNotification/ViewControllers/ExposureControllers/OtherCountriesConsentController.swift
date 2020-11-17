import UIKit

protocol  OtherCountriesConsentControllerDelegate: class {
    func didChangeConsentToFederation()
}

class OtherCountriesConsentController: UIViewController {
    
    @IBOutlet weak var consentSwitchContainerView: UIView!
    @IBOutlet weak var consentSwitchTitle: UILabel!
    @IBOutlet weak var consentSwitch: UISwitch!
    
    public weak var delegateConsent: OtherCountriesConsentControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConsentSwitch()
    }
    
    private func setupConsentSwitch() {
        if LocalStorage.shared.consentToFederation {
            consentSwitchContainerView.backgroundColor = .primaryGreen
            consentSwitch.setOn(true, animated: true)
            consentSwitchTitle.text = "OtherCountriesConsentController.SwitchOn".localized()
            consentSwitchTitle.textColor = .white
        } else {
            consentSwitchContainerView.backgroundColor = .backgroundLightGray
            consentSwitch.setOn(false, animated: true)
            consentSwitchTitle.text = "OtherCountriesConsentController.SwitchOff".localized()
            consentSwitchTitle.textColor = .black
        }
        delegateConsent?.didChangeConsentToFederation()
    }
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    
    @IBAction func consent() {
        if !LocalStorage.shared.consentToFederation {
            UIUtil.showInfoAlertWithHandler(viewController: self, title: "OtherCountriesConsentController.PopupTitle".localized(),
                                            negativeBtnText: "OtherCountriesConsentController.PopupCancel".localized(),
                                            positiveBtnText: "OtherCountriesConsentController.PopupAccept".localized(),
                                            messageText: "OtherCountriesConsentController.PopupMessage".localized(),
                                            didChoosePositive: {
                                                LocalStorage.shared.consentToFederation = true
                                                self.setupConsentSwitch()
                                            },
                                            didChooseNegative: {
                                                LocalStorage.shared.consentToFederation = false
                                                self.setupConsentSwitch()
                                            })
        } else {
            LocalStorage.shared.consentToFederation = false
            setupConsentSwitch()
        }
    }
    
    deinit {
        print("DEINIT OtherCountriesConsentController")
    }
}
