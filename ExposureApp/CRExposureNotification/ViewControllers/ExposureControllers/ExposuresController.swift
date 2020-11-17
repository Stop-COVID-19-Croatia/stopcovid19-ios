import UIKit
import ExposureNotification

class ExposuresController: UIViewController {
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ivStatus: LottieCustomView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var internationalLabel: UILabel!
    
    @IBOutlet weak var exposureDetectionContainer: UIView!
    @IBOutlet weak var exposureInfoContainer: UIView!
    @IBOutlet weak var internationalExchangeContainer: UIView!
    @IBOutlet weak var ivExposureInfo: LottieCustomView!
    @IBOutlet weak var lblExposureInfo: UILabel!
    @IBOutlet weak var lblNoItem: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    
    private var transmisionRisk: TransmissionRisk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(ivStatus.animationView?.isAnimationPlaying ?? false) {
            ivStatus.animationView?.play()
        }
        
        if !(ivExposureInfo.animationView?.isAnimationPlaying ?? false) {
            ivExposureInfo.animationView?.play()
        }
    }
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupExposureInfo), name: .updateExposureController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExposureNotificationStatus), name: .updateBluetooth, object: nil)
        setupExposureInfo()
        setupLanguage()
        handleExposureNotificationStatus()
    }
    
    @objc private func setupExposureInfo() {
        guard let transmissionRisk = LocalStorage.shared.transmissionRisk else {
            lblNoItem.isHidden = false
            exposureDetectionContainer.isHidden = true
            return
        }
        
        lblNoItem.isHidden = true
        exposureDetectionContainer.isHidden = false
        self.transmisionRisk = transmissionRisk
        lblExposureInfo.text = transmissionRisk.riskTitle
        
        if transmissionRisk.riskType == .highRisk {
            ivExposureInfo.setAnimations(name: "icon-risk-high-details-anim")
        } else {
            ivExposureInfo.setAnimations(name: "icon-risk-details-anim")
        }
        updateViewWithAnim()
    }
    
    private func setupLanguage() {
        titleLabel.text = "ExposuresController.Title".localized()
        languageLabel.text = Language.getDefaultLanguage().shortTitle?.uppercased()
    }
    
    @objc public func handleExposureNotificationStatus() {
        switch ExposureManager.shared.manager.exposureNotificationStatus {
        case .active:
            if ENManager.authorizationStatus == .authorized {
                setInternationalExchange(visibility: true)
                lblNoItem.text = "ExposuresController.OnMessage".localized()
            } else {
                setInternationalExchange(visibility: false)
                if UIDevice.current.systemVersion == "13.7" {
                    lblNoItem.text = "ExposureController.ENAppRestricted13.7Label".localized()
                } else {
                    lblNoItem.text = "ExposuresController.OffMessage".localized()
                }
            }
            
        case .restricted, .unauthorized, .unknown:
            setInternationalExchange(visibility: false)
            if #available(iOS 13.7, *) {
                if  ENManager.authorizationStatus == .unknown {
                    lblNoItem.text = "ExposuresController.OffMessage".localized()
                } else {
                    if UIDevice.current.systemVersion == "13.7" {
                        lblNoItem.text = "ExposureController.ENAppRestricted13.7Label".localized()
                    } else {
                        lblNoItem.text = "ExposuresController.OffMessage".localized()
                    }
                }
            } else {
                lblNoItem.text = "ExposuresController.OffMessage".localized()
            }
            
        case .bluetoothOff:
            setInternationalExchange(visibility: true)
            lblNoItem.text = "ExposuresController.BluetoothOff".localized()
        default:
            setInternationalExchange(visibility: false)
            lblNoItem.text = "ExposuresController.OffMessage".localized()
        }
        
        setupStatusView()
    }
    
    private func setupStatusView() {
        if ExposureManager.shared.manager.exposureNotificationEnabled &&
            ExposureManager.shared.manager.exposureNotificationStatus == .active &&
            ENManager.authorizationStatus == .authorized {
            statusContainerView.backgroundColor = .primaryGreen
            statusSwitch.setOn(true, animated: true)
            statusLabel.text = "ExposuresController.On".localized()
            ivStatus.setAnimations(name: "icon-contacts-anim")
            statusLabel.textColor = .white
        } else {
            statusContainerView.backgroundColor = .backgroundLightGray
            statusSwitch.setOn(false, animated: true)
            statusLabel.text = "ExposuresController.Off".localized()
            ivStatus.setAnimations(name: "icon-nocontacts-anim")
            statusLabel.textColor = .black
        }
    }
    
    private func setInternationalExchange(visibility: Bool) {
        internationalExchangeContainer.isHidden = !visibility
        let status = LocalStorage.shared.consentToFederation ? "ExposuresController.InternationalExchangeOn".localized() : "ExposuresController.InternationalExchangeOff".localized()
        let color = LocalStorage.shared.consentToFederation ? UIColor.primaryGreen : UIColor.primaryRed

        internationalLabel.text = String(format: "ExposuresController.InternationalExchangeFormat".localized(), status)
        
        internationalLabel.partTextModifier(fullText: internationalLabel.text ?? Constants.emptyString, changeText: status, color: color, font: UIFont.sfCompactRegularBold(ofSize: 14))
    }
    
    @IBAction func changeLanguage() {
        if Language.getDefaultLanguage().languageType == .english {
            Language.setDefaultLanguage(language: Language.findLanguageByType(languageType: .croatian))
        } else {
            Language.setDefaultLanguage(language: Language.findLanguageByType(languageType: .english))
        }
        
        if let controller = tabBarController as? TabbarController {
            controller.languageChanged()
        }
        
        setup()
    }
    
    @IBAction func exposuresSwitch() {
        if ExposureManager.shared.manager.exposureNotificationEnabled &&
            ExposureManager.shared.manager.exposureNotificationStatus == .active &&
            ENManager.authorizationStatus == .authorized {
            if #available(iOS 13.7, *) {
                UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.TurnOffEN13.7".localized()) {
                    self.openSettings()
                }
            } else {
                UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.TurnOffEN".localized()) {
                    self.openSettings()
                }
            }
            return
        }
        
        ExposureManager.setEnableExposureNotifications(isEnabled: true, completionHandler: { error in
            DispatchQueue.main.async {
                if LocalStorage.shared.passedEnableExposure == nil {
                    LocalStorage.shared.passedEnableExposure = true
                    self.handleExposureNotificationStatus()
                    self.setupLanguage()
                    return
                }
                
                self.handleExposureNotificationStatus()
                self.showUIAlert(error)
            }
        })
    }
    
    private func showUIAlert(_ error: CustomError?) {
        switch ExposureManager.shared.manager.exposureNotificationStatus {
        case .active:
            if ENManager.authorizationStatus != .authorized {
                if #available(iOS 13.7, *) {
                    if UIDevice.current.systemVersion == "13.7" {
                        UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.TurnOnEN13.7".localized()) {
                            self.openSettings()
                        }
                    } else{
                        UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.ENAppRestricted13.7".localized()) {
                            self.openSettings()
                        }
                    }
                } else {
                    UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.ENRestricted".localized()) {
                        self.openSettings()
                    }
                }
            }
            
        case .restricted, .unauthorized, .unknown:
            if #available(iOS 13.7, *) {
                UIUtil.showErrorAlert(viewController: self, title: "ExposureController.Info".localized(), message: "ExposureController.ENRestricted13.7".localized()) {
                    self.openSettings()
                }
            } else {
                UIUtil.showErrorAlert(viewController: self, message: "ExposureController.ENRestricted".localized()) {
                    self.openSettings()
                }
            }
            
        case .bluetoothOff:
            UIUtil.showErrorAlert(viewController: self, message: "ExposuresController.BluetoothOff".localized())
            
        default:
            if let error = error {
                ErrorHandler.handle(error: error, in: self)
            }
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        
        UIApplication.shared.open(settingsUrl)
    }
    
    deinit {
        print("DEINIT ExposureController")
    }
    
    @IBAction func previewExposure(_ sender: UIButton) {
        if let transmisionRisk = transmisionRisk {
            present(ExposuresDetailsController.instantiate(transmisionRisk: transmisionRisk), animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == "otherCountrySegue",
            let controller = segue.destination as? OtherCountriesConsentController {
            controller.delegateConsent = self
        }
    }
}

extension ExposuresController: OtherCountriesConsentControllerDelegate {
    func didChangeConsentToFederation() {
        setInternationalExchange(visibility: true)
    }
}
