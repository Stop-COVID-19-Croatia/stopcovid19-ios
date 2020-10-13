import UIKit
import ExposureNotification

class ExposuresController: UIViewController {
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var exposureDetectionContainer: UIView!
    @IBOutlet weak var exposureInfoContainer: UIView!
    @IBOutlet weak var ivExposureInfo: UIImageView!
    @IBOutlet weak var lblExposureInfo: UILabel!
    @IBOutlet weak var lblNoItem: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    
    private var transmisionRisk: TransmissionRisk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
            exposureInfoContainer.isHidden = true
            return
        }
        
        lblNoItem.isHidden = true
        exposureInfoContainer.isHidden = false
        self.transmisionRisk = transmissionRisk
        lblExposureInfo.text = transmissionRisk.riskTitle
        
        if transmissionRisk.riskType == .highRisk {
            ivExposureInfo.image = UIImage(named: "icon-risk-high-details")
        } else {
            ivExposureInfo.image = UIImage(named: "icon-risk-details")
        }
    }
    
    private func setupLanguage() {
        titleLabel.text = "ExposuresController.Title".localized()
        languageLabel.text = Language.getDefaultLanguage().shortTitle?.uppercased()
    }
    
    @objc public func handleExposureNotificationStatus() {
        switch ExposureManager.shared.manager.exposureNotificationStatus {
        case .active:
            if ENManager.authorizationStatus == .authorized {
                lblNoItem.text = "ExposuresController.OnMessage".localized()
            } else {
                if UIDevice.current.systemVersion == "13.7" {
                    lblNoItem.text = "ExposureController.ENAppRestricted13.7Label".localized()
                } else {
                    lblNoItem.text = "ExposuresController.OffMessage".localized()
                }
            }
            
        case .restricted, .unauthorized, .unknown:
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
            lblNoItem.text = "ExposuresController.BluetoothOff".localized()
            
        default:
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
            ivStatus.image = UIImage(named: "icon-contacts")
            statusLabel.textColor = .white
        } else {
            statusContainerView.backgroundColor = .backgroundLightGray
            statusSwitch.setOn(false, animated: true)
            statusLabel.text = "ExposuresController.Off".localized()
            ivStatus.image = UIImage(named: "icon-nocontacts")
            statusLabel.textColor = .black
        }
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
}
